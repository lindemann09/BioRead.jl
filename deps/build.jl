using Conda

# install bioread from pip
Conda.pip_interop(true, Conda.ROOTENV)
Conda.pip("install", "bioread")