import os
import sys

import numpy as np
from PIL import Image

WIDTH = 1024
HEIGHT = 256
ASPECT = 4.0
FRAMES = 20
SOFT = 0.1
SEED = 7

SEEDS = [
    (0.36, 0.5, 0.0),
    (0.8, 0.75, 0.12),
    (0.12, 0.3, 0.2),
    (0.62, 0.28, 0.28),
]


def make_lattice(rng, size):
    return rng.random((size, size))


def value_noise(lattice, x, y):
    size = lattice.shape[0]
    xi = np.floor(x).astype(int)
    yi = np.floor(y).astype(int)
    xf = x - xi
    yf = y - yi
    u = xf * xf * (3 - 2 * xf)
    v = yf * yf * (3 - 2 * yf)
    x0 = xi % size
    y0 = yi % size
    x1 = (xi + 1) % size
    y1 = (yi + 1) % size
    a = lattice[y0, x0]
    b = lattice[y0, x1]
    c = lattice[y1, x0]
    d = lattice[y1, x1]
    return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v


def fbm(lattice, x, y, octaves, gain=0.5, lacunarity=2.03):
    total = np.zeros_like(x)
    amplitude = 1.0
    norm = 0.0
    frequency = 1.0
    for _ in range(octaves):
        total += amplitude * value_noise(lattice, x * frequency, y * frequency)
        norm += amplitude
        amplitude *= gain
        frequency *= lacunarity
    return total / norm


def build_threshold_map():
    rng = np.random.default_rng(SEED)
    lattices = [make_lattice(rng, 64) for _ in range(4)]
    xs = (np.arange(WIDTH) + 0.5) / WIDTH * ASPECT
    ys = (np.arange(HEIGHT) + 0.5) / HEIGHT
    x, y = np.meshgrid(xs, ys)

    warp_x = (fbm(lattices[0], x * 1.1, y * 2.6, 4) - 0.5) * 0.9
    warp_y = (fbm(lattices[1], x * 1.1 + 9.1, y * 2.6 + 3.7, 4) - 0.5) * 0.6
    wx = x + warp_x
    wy = y + warp_y

    base = np.full_like(x, np.inf)
    for sx, sy, delay in SEEDS:
        distance = np.sqrt((wx - sx * ASPECT) ** 2 + (wy - sy) ** 2)
        base = np.minimum(base, delay + distance * 0.35)

    cloud = (fbm(lattices[2], x * 3.0, y * 7.0, 5) - 0.5) * 0.35
    ragged = (fbm(lattices[3], x * 16.0, y * 40.0, 3) - 0.5) * 0.09
    threshold = base + cloud + ragged

    low = np.percentile(threshold, 0.5)
    high = np.percentile(threshold, 99.5)
    return np.clip((threshold - low) / (high - low), 0.0, 1.0)


def smoothstep(values):
    values = np.clip(values, 0.0, 1.0)
    return values * values * (3 - 2 * values)


def main(out_dir):
    os.makedirs(out_dir, exist_ok=True)
    threshold = build_threshold_map() * (1 - SOFT)
    for index in range(FRAMES):
        progress = index / (FRAMES - 1)
        alpha = smoothstep((progress - threshold) / SOFT)
        if index == 0:
            alpha = np.zeros_like(alpha)
        pixels = np.zeros((HEIGHT, WIDTH, 4), dtype=np.uint8)
        pixels[..., 0:3] = 255
        pixels[..., 3] = np.round(alpha * 255).astype(np.uint8)
        Image.fromarray(pixels, "RGBA").save(os.path.join(out_dir, "bleed_%02d.png" % (index + 1)), optimize=True)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "Textures/questview/bleed")
