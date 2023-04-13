from typing import List, Dict
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
    G = 10 ** 5

    def __init__(self, steps: int, delta: float, objects: List[MassObject]):
        self.objects = objects
        self.delta = delta
        self.steps = steps

    def solve(self):
        for step in range(self.steps):
            snapshots = dict(
                map(lambda key:
                    (key, self.objects[:self.objects.index(key)] + self.objects[self.objects.index(key) + 1:]),
                    self.objects))
            updated = dict(map(lambda item: (item[0], calc_step(self.delta, item[0], item[1])), snapshots.items()))
            if any_collided(updated):
                return {"last_state": snapshots, "result": "collision", "valid_steps": step}
            self.objects = list(updated.values())
        return {"last_state": self.objects, "result": "done"}


def calc_step(delta: float, body: MassObject, others: List[MassObject]) -> MassObject:
    G = 10 ** 5
    force = np.array((0., 0.))
    for other in others:
        distance = np.linalg.norm(body.position - other.position)
        direction = (other.position - body.position)/distance
        force += direction * ((G * other.mass * body.mass)/(distance**2))
    acceleration = force/body.mass
    velocity_delta = acceleration * delta
    linear_velocity = velocity_delta + body.linear_velocity
    position_delta = linear_velocity * delta
    return MassObject(body.name, body.radius, body.mass, position_delta+body.position, linear_velocity)


def get_position_diff(a: MassObject, b: MassObject) -> (np.ndarray, np.ndarray):
    position = a.position
    vector_movement = b.position - a.position
    return position, vector_movement


def is_between(x: float, y: float, a: float):
    mi = min(x, y)
    mx = max(x, y)
    return mi < a < mx


def point_provider(vector: np.ndarray, start: np.ndarray, t: float):
    return vector*t + start


def any_collided(updates: Dict[MassObject, MassObject]):
    keys = list(updates.keys())
    key_a: MassObject
    key_b: MassObject
    for a, key_a in enumerate(keys[:-1]):
        a_vector: np.ndarray = updates[key_a].position - key_a.position
        for b, key_b in enumerate(keys[a+1:]):
            b_vector = updates[key_b].position - key_b.position
            t = 0.
            if np.linalg.norm(a_vector) / key_a.radius > np.linalg.norm(b_vector) / key_b.radius:
                t_step = key_a.radius / np.linalg.norm(a_vector)
            else:
                t_step = key_b.radius / np.linalg.norm(b_vector)
            t_step = t_step if t_step < 1 else 1
            while t < 1:
                a_point = point_provider(a_vector, key_a.position, t)
                b_point = point_provider(b_vector, key_b.position, t)
                if np.linalg.norm(a_point-b_point) < key_a.radius + key_b.radius:
                    return True
                t += t_step
    return False


if __name__ == "__main__":
    world = Simulator(delta=1/60, steps=500, objects=[
        MassObject(name="A", mass=10, position=np.array((100., 0.)), linear_velocity=np.array((0., 100.)), radius=9),
        MassObject(name="B", mass=10, position=np.array((-100., 0.)), linear_velocity=np.array((0., -100.)), radius=9)
    ])
    res = world.solve()
    print(res["result"])
