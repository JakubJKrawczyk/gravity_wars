import abc
import os
from abc import ABC
from dataclasses import dataclass, field
from multiprocessing.pool import Pool
from random import randint, shuffle
from typing import Self, List


class ObjectGen:
    linear_velocity_x: int
    linear_velocity_y: int
    position_x: int
    position_y: int
    mass: int
    radius: int
    freeze: list = field(default_factory=list)
    scale: int = 10 ** 6


class Chromosome:
    objects: List[ObjectGen | None]


class GeneticFitnessStrategy(ABC):
    @abc.abstractmethod
    def get_fitness(self, chromosome: Chromosome):
        pass


def cross_int(a: int, b: int):
    x = randint(1, min(abs(a), abs(b)))
    return (x * (a // x)) + (b % x)


@dataclass
class ObjectGen:
    linear_velocity_x: int
    linear_velocity_y: int
    position_x: int
    position_y: int
    mass: int
    radius: int
    freeze: list = field(default_factory=list)
    scale: int = 10 ** 6

    @staticmethod
    def new_random(scale: int):
        return ObjectGen(linear_velocity_x=randint(-(10 ** 10), 10 ** 10),
                         linear_velocity_y=randint(-(10 ** 10), 10 ** 10),
                         position_x=randint(-scale * 300, scale * 300), position_y=randint(-scale * 300, scale * 300),
                         mass=randint(scale, scale * 100), radius=randint(5, 25))

    def fill_partially_inited(self):
        if self.linear_velocity_x is None:
            self.linear_velocity_x = randint(-(10 ** 10), 10 ** 10)
        if self.linear_velocity_y is None:
            self.linear_velocity_y = randint(-(10 ** 10), 10 ** 10)
        if self.position_x is None:
            self.position_x = randint(-self.scale * 300, self.scale * 300)
        if self.position_y is None:
            self.position_y = randint(-self.scale * 300, self.scale * 300)
        if self.mass is None:
            self.mass = randint(self.scale, self.scale * 100)
        if self.radius is None:
            self.radius = randint(5, 25)

    def cross(self, parent: Self):
        if self.scale != parent.scale:
            raise Exception("Different scales")
        velocity_x = cross_int(self.linear_velocity_x, parent.linear_velocity_x)
        velocity_y = cross_int(self.linear_velocity_y, parent.linear_velocity_y)
        position_x = cross_int(self.position_x, parent.position_x)
        position_y = cross_int(self.position_y, parent.position_y)
        mass = cross_int(self.mass, parent.mass)
        radius = cross_int(self.radius, parent.radius)
        return ObjectGen(velocity_x, velocity_y, position_x, position_y, mass, radius,
                         scale=self.scale, freeze=self.freeze)

    def mutate(self, probability: float):
        if "linear_velocity_x" not in self.freeze and probability < randint(0, 100) / 100:
            self.linear_velocity_x = randint(-(10 ** 10), 10 ** 10)
        if "linear_velocity_y" not in self.freeze and probability < randint(0, 100) / 100:
            self.linear_velocity_y = randint(-(10 ** 10), 10 ** 10)
        if "position_x" not in self.freeze and probability < randint(0, 100) / 100:
            self.position_x = randint(-self.scale * 300, self.scale * 300)
        if "position_y" not in self.freeze and probability < randint(0, 100) / 100:
            self.position_y = randint(-self.scale * 300, self.scale * 300)
        if "mass" not in self.freeze and probability < randint(0, 100) / 100:
            self.mass = randint(self.scale, self.scale * 100)
        if "radius" not in self.freeze and probability < randint(0, 100) / 100:
            self.radius = randint(5, 25)

    def __hash__(self):
        return hash((self.mass, self.radius, self.scale, self.position_x, self.position_y,
                     self.linear_velocity_x, self.linear_velocity_y))


# noinspection PyRedeclaration
class Chromosome:
    objects: List[ObjectGen | None]
    fitness_strategy: GeneticFitnessStrategy

    def __init__(self, objects: List[ObjectGen | None], fitness_calculator: GeneticFitnessStrategy):
        self.objects = objects
        for index, obj in enumerate(objects):
            if obj is None:
                self.objects[index] = ObjectGen.new_random(10**6)
            else:
                obj.fill_partially_inited()
        self.fitness_strategy = fitness_calculator

    @staticmethod
    def new_random(objects: int, fitness_calculator: GeneticFitnessStrategy, init: Chromosome | None):
        ret = Chromosome([ObjectGen.new_random(10 ** 6) for _ in range(objects)], fitness_calculator)
        if init is None:
            return ret
        obj: ObjectGen
        reo: ObjectGen
        for reo, obj in zip(ret.objects, init.objects):
            reo.linear_velocity_x = reo.linear_velocity_x if obj.linear_velocity_x is None else obj.linear_velocity_x
            reo.linear_velocity_y = reo.linear_velocity_y if obj.linear_velocity_y is None else obj.linear_velocity_y
            reo.position_x = reo.position_x if obj.position_x is None else obj.position_x
            reo.position_y = reo.position_y if obj.position_y is None else obj.position_y
            reo.radius = reo.radius if obj.radius is None else obj.radius
            reo.mass = reo.mass if obj.mass is None else obj.mass
        return ret

    def cross(self, parent: Self):
        if len(parent.objects) != len(self.objects):
            raise Exception("Different chromosome")
        objects = list(map(lambda pair: pair[0].cross(pair[1]), zip(self.objects, parent.objects)))
        return Chromosome(objects, self.fitness_strategy)

    def mutate(self, object_probability: float, param_probability: float):
        for obj in self.objects:
            if object_probability < randint(0, 100) / 100:
                continue
            obj.mutate(param_probability)

    def calc_fitness(self):
        return self.fitness_strategy.get_fitness(self)

    def fill_missing(self, objects_per_set):
        for _ in range(objects_per_set - len(self.objects)):
            self.objects.append(ObjectGen.new_random(10**6))


class GeneticProblem:
    _population: List[Chromosome]

    max_population: int
    children_population: int
    gen_mutation_probability: float
    param_mutation_probability: float
    fitness_calculator: GeneticFitnessStrategy
    epochs: int

    def __init__(self, population: int, children: int, fitness_calculator: GeneticFitnessStrategy, epochs: int,
                 objects_per_set: int = 3, gen_mutation: float = 0.2, param_mutation: float = 0.1,
                 init_chromosome: Chromosome | None = None):
        self.epochs = epochs
        self.fitness_calculator = fitness_calculator
        self.param_mutation_probability = param_mutation
        self.gen_mutation_probability = gen_mutation
        self.max_population = population
        self.children_population = children
        if init_chromosome is not None:
            init_chromosome.fill_missing(objects_per_set)
        self._population = [Chromosome.new_random(objects_per_set, self.fitness_calculator, init_chromosome)
                            for _ in range(population)]
        
    def solve(self):
        for i in range(1, self.epochs + 1):
            children_population = self.cross()
            self._population = self.selection(children_population)
            if i != self.epochs:
                self.mutate()
            if i % (self.epochs//100) == 0:
                print(f"Solving: {i}/{self.epochs}\t{self._population[0].calc_fitness()}")
        return self._population[0]

    def cross(self) -> List[Chromosome]:
        population: list[Chromosome] = []
        for _ in range(self.children_population):
            shuffle(self._population)
            p1, p2 = self._population[:2]
            population.append(p1.cross(p2))
        return population

    def map_fitness(self, c: Chromosome):
        return c, c.calc_fitness()

    def selection(self, children: List[Chromosome]) -> List[Chromosome]:
        pool: Pool = Pool(os.cpu_count() - 1)
        sort = list(pool.map(self.map_fitness, children))
        pool.close()
        sort = sorted(sort, key=lambda x: x[1], reverse=True)
        sort = list(map(lambda x: x[0], sort))
        return sort[:self.max_population]

    def mutate(self):
        for chromosome in self._population:
            chromosome.mutate(self.gen_mutation_probability, self.param_mutation_probability)
    
