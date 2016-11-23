#!/bin/bash

cd /opt/trinitycore/data
time ../bin/mapextractor
time ../bin/vmap4extractor
mkdir vmaps
time ../bin/vmap4assembler Buildings vmaps
mkdir mmaps
time ../bin/mmaps_generator --threads `nproc`

