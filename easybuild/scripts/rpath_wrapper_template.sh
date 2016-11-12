#!/bin/bash
##
# Copyright 2016-2016 Ghent University
#
# This file is part of EasyBuild,
# originally created by the HPC team of Ghent University (http://ugent.be/hpc/en),
# with support of Ghent University (http://ugent.be/hpc),
# the Flemish Supercomputer Centre (VSC) (https://www.vscentrum.be),
# Flemish Research Foundation (FWO) (http://www.fwo.be/en)
# and the Department of Economy, Science and Innovation (EWI) (http://www.ewi-vlaanderen.be/en).
#
# http://github.com/hpcugent/easybuild
#
# EasyBuild is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation v2.
#
# EasyBuild is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with EasyBuild.  If not, see <http://www.gnu.org/licenses/>.
##

# Template wrapper script for compiler/linker commands,
# which calls out to a Python script (rpath_args.py) to preprocess
# the list of command line arguments, injecting -rpath flags, etc.,
# before actually calling the original compiler/linker command.
#
# All %(foo)s substrings are template values that will be filled by EasyBuild.
#
# author: Kenneth Hoste (HPC-UGent)

set -e

# logging function
function log {
    # escape '%' with another '%', since this is a template script
    echo "($$) [$(date "+%%Y-%%m-%%d %%H:%%M:%%S")] $1" >> %(rpath_wrapper_log)s
}

# command name
CMD=`basename $0`

log "found CMD: $CMD | original command: %(orig_cmd)s | orig args: '$(echo \"$@\")'"

# rpath_args.py script spits out statement that defines $CMD_ARGS
rpath_args_out=$(%(python)s -O %(rpath_args_py)s $CMD '%(rpath_filter)s' "$@")

log "rpath_args_out:
$rpath_args_out"

# define $CMD_ARGS by evaluating output of rpath_args.py script
eval $rpath_args_out

# call original command with modified list of command line arguments
log "running '%(orig_cmd)s $(echo ${CMD_ARGS[@]})'"
%(orig_cmd)s "${CMD_ARGS[@]}"
