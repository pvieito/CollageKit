#!/usr/bin/env python3
'''CollageTool.py - Pedro José Pereira Vieito © 2016
    Picasa CXF Collage Files Inspector.

Usage:
    CollageTool.py <file> [--scale=<sc>]

Options:
    --scale=<sc>  Image scale [default: 10]
    -h, --help    Show this help
'''

import sys
import untangle
import struct
import os
import glob
from PIL import Image
from docopt import docopt

__author__ = "Pedro José Pereira Vieito"
__email__ = "pvieito@gmail.com"


def render_collage(file):
    cxf = untangle.parse(file)
    cxf = cxf.collage
    print('Title:', cxf.albumTitle.cdata)
    print('Date:', cxf.albumDate.cdata)
    print('Format:', cxf['format'])

    format = cxf['format'].split(':')
    scale = int(args['--scale'])
    width = int(format[0]) * scale
    length = int(format[1]) * scale

    # What The Hell, Spacing
    spacing = float(cxf.spacing['value'])
    spacing = int((0.0978 * spacing ** 2 - 0.0145 * spacing + 0.0157) * width)

    print('Size:', width, '×', length)
    print('Scale:', scale)
    print('Spacing:', spacing)

    background = struct.unpack('BBBB',
                               bytes.fromhex(cxf.background['color']))[:3]
    collage = Image.new('RGB', (width + spacing, length + spacing), background)

    for node in cxf.node:
        if os.path.isfile(node.src.cdata):
            x = int(float(node['x']) * width) + spacing
            y = int(float(node['y']) * length) + spacing
            w = int(float(node['w']) * width) - spacing
            h = int(float(node['h']) * length) - spacing

            image = Image.open(node.src.cdata)
            size = image.size
            ratio_collage = w / h
            ratio_image = size[0] / size[1]

            if ratio_collage > ratio_image:
                resize = (w, int(w / size[0] * size[1]))
            else:
                resize = (int(h / size[1] * size[0]), h)

            image = image.resize(resize)
            ax = int((image.size[0] - w) / 2)
            ay = int((image.size[1] - h) / 2)
            bx = ax + w
            by = ay + h
            image = image.crop((ax, ay, bx, by))
            (w, h) = image.size
            collage.paste(image, (x, y, x + w, y + h))

        else:
            print('[ERROR] Image not found:', node.src.cdata)

    collage.show(cxf.albumTitle.cdata)

args = docopt(__doc__)
file = args['<file>'].rstrip("/")

if not os.path.isfile(file):
    if os.path.isdir(file) and os.path.splitext(file)[1] == '.picasalibrary':
        print('Collage bundle found!')
        os.chdir(os.path.join(file, 'Collages'))
        cxf_files = glob.glob("*.cxf")
        i = 1
        for cxf_file in cxf_files:
            try:
                render_collage(cxf_file)
            except Exception as error:
                jpg_file = cxf_file.replace(".cxf", ".jpg")
                print('[INFO] Showing prerendered image:', jpg_file)
                os.system('open "' + jpg_file + '"')
    else:
        print('Picasa CLX Collage file or Collage Bundle not found.')
        exit(0)
else:
    render_collage(file)
