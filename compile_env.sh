#!/bin/bash
resetpath
initspack
spack load binutils %gcc@5
spack load gcc@5
spack load hdf5 %gcc@5
spack load fftw@2 %gcc@5
spack load gsl %gcc@5
spack load mvapich2 %gcc@5
