#!/bin/bash

# Force working inside of a Python virtual environment
export PIP_REQUIRE_VIRTUALENV=true

# Install Python dependencies
python -m pip --quiet install --upgrade pip setuptools wheel
python -m pip --quiet install --upgrade 'recast-atlas[local]>=0.3.0' coolname

# Authenticate
# Set these variables to your personal secret values
export RECAST_AUTH_USERNAME=#USERNAME
export RECAST_AUTH_PASSWORD=#SECRET
export RECAST_AUTH_TOKEN=#SECRET

eval "$(recast auth setup -a ${RECAST_AUTH_USERNAME} -a ${RECAST_AUTH_PASSWORD} -a ${RECAST_AUTH_TOKEN} -a default)"
eval "$(recast auth write --basedir authdir)"

# Unset after authdir creation to avoid secrets in memory
unset RECAST_AUTH_USERNAME
unset RECAST_AUTH_PASSWORD
unset RECAST_AUTH_TOKEN

# Add the workflow
# Use a subshell for catalogue add to evaluate the shell export it produces
printf '\n# $(recast catalogue add "${PWD}")\n'
$(recast catalogue add "${PWD}")

printf '\n# echo "${RECAST_ATLAS_CATALOGUE}"\n'
echo "${RECAST_ATLAS_CATALOGUE}"

printf '\n# recast catalogue ls\n'
recast catalogue ls

printf '\n# recast catalogue describe examples/helloworld\n'
recast catalogue describe examples/helloworld

printf '\n# recast catalogue check examples/helloworld\n'
recast catalogue check examples/helloworld

# Run the workflow
# The default --example value is 'default'
_default_tag=$(coolname 2)
printf '\n# recast run --backend docker --tag '"default-${_default_tag}"' examples/helloworld\n'
recast run \
    --backend docker \
    --tag "default-${_default_tag}" \
    examples/helloworld

_local_tag=$(coolname 2)
printf '\n# recast run --backend local --tag '"local-${_local_tag}"' examples/helloworld\n'
recast run \
    --backend local \
    --tag "local-${_local_tag}" \
    examples/helloworld

_alt_tag=$(coolname 2)
printf '\n# recast run --example alternative --backend docker --tag '"alternative-${_alt_tag}"' examples/helloworld\n'
recast run \
    --example alternative \
    --backend docker \
    --tag "alternative-${_alt_tag}" \
    examples/helloworld

# Cleanup authenticaion secrets and environmental variables
eval $(recast auth destroy)
