import numpy as np

from tools.genetic import GeneticFitnessStrategy, Chromosome, ObjectGen
from tools.simulator import MassObject, Simulator


class SimulationGfs(GeneticFitnessStrategy):

    @staticmethod
    def gen_to_mass_object(gen: ObjectGen) -> MassObject:
        return MassObject(mass=gen.mass/gen.scale, radius=gen.radius,
                          position=np.array((gen.position_x/gen.scale, gen.position_y/gen.scale)),
                          linear_velocity=np.array((gen.linear_velocity_x/gen.scale, gen.linear_velocity_y/gen.scale)),
                          name=str(hash(gen)))

    def get_fitness(self, chromosome: Chromosome):
        objects = list(map(lambda x: self.gen_to_mass_object(x), chromosome.objects))
        simulation = Simulator(steps=60*60, delta=1/60, objects=objects)
        result = simulation.solve()
        if result["result"] == "collision":
            return result["valid_steps"] - (60*60)
        value = map(lambda mobject: np.linalg.norm(mobject.position), result["last_state"])
        return sum(map(lambda v: 10 if v <= 300 else 10/(v-300), value))
