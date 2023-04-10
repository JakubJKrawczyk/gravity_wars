from typing import List
import numpy as np


class MassObject:
    name: str
    radius: float
    mass: float
    position: np.ndarray
    linear_velocity: np.ndarray

    def __init__(self, name, radius, mass, position, linear_velocity):
        self.linear_velocity = linear_velocity
        self.position = position
        self.mass = mass
        self.radius = radius
        self.name = name


class Simulator:
    steps: int
    objects: List[MassObject]
    delta: float
    G = 10**5

    def __init__(self, steps: int, delta: float, objects: List[MassObject]):
        self.objects = objects
        self.delta = delta
        self.steps = steps

    def solve(self):
        pass
