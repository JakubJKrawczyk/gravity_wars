from tools.SimulationGfs import SimulationGfs
from tools.genetic import GeneticProblem, Chromosome


def main():
    genetic_solve = GeneticProblem(population=100, children=300, fitness_calculator=SimulationGfs(), epochs=100)
    print("Data prepared, started solving")
    top: Chromosome = genetic_solve.solve()
    for index, star in enumerate(top.objects):
        print(f"{index}.\tmass: {star.mass/star.scale}, radius: {star.radius},"
              f"x: {star.position_x/star.scale}, y: {star.position_y/star.scale},"
              f"v_x {star.linear_velocity_x/star.scale}, v_y: {star.linear_velocity_y/star.scale}")
    print(f"Fitness: {top.calc_fitness()}")


if __name__ == "__main__":
    main()
