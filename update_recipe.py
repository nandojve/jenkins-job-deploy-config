#!/usr/bin/env python
from __future__ import print_function

import os
import sys
import subprocess

def get_last_repo_sha1(repository, branch):
    """ Get the last sha1 from a specific repository.
    """
    cmd = ['git', 'ls-remote', repository, branch]
    output = subprocess.check_output(cmd)
    return output.split('\t')[0]


def clean_hash_conf(conf):
    """ Clean all content of hash conf file
    """
    try:
        hash_path = os.getcwd() + '/' + conf + '/conf/hash.conf'
        if os.path.exists(hash_path):
            os.remove(hash_path)
    except Exception:
        print('Cannot clean file: %s', hash_path)
        sys.exit(1)


def add_recipe_sha1(conf, pkg, branch, new_sha):
    """ Change the sha1/branch value for specific recipe.
    """
    try:
        local_conf_dir = os.getcwd() + '/' + conf + '/conf'
        if not os.path.exists(local_conf_dir):
            os.makedirs(local_conf_dir)
        hash_path = local_conf_dir + '/hash.conf'
        fd = open(hash_path, 'a')
        fd.write('\n')
        fd.write('SRCREV_pn-' + pkg + ' = "' + new_sha + '"\n')
        fd.write('SRCBRANCH_pn-' + pkg + ' = "' + branch + '"\n')
        fd.flush()
        fd.close()
    except Exception:
        print('Cannot add for recipe: %s', recipe)
        sys.exit(1)


def print_recipe_information(pkg, branch, sha):
    """
    """
    ref = 30
    length = len(pkg)
    if length >= ref:
        key = key[:ref - 4]
        blank = '... '
    else:
        blank = ' ' * (ref - length)

    print(pkg + blank + ': ' + sha + ' /' + branch)


def update_recipes(configuration):
    """ Update the recipe's sha1 from all monitored repositories using [configuration]
    """
    try:
        configuration_path = '/sources/conf/jenkins/job-deploy-config/' + configuration + '.conf'
        configuration_full_path = os.getcwd() + configuration_path
        fd = open(configuration_full_path, 'r')

        clean_hash_conf(configuration)

        for line in fd.readlines():
            pkg, version, srcrev, branch, repository = line.split()
            last_sha = get_last_repo_sha1(repository, branch)
            add_recipe_sha1(configuration, pkg, branch, last_sha)
            print_recipe_information(pkg, branch, last_sha)

    except Exception:
        print('Doesn\'t exists configuration file: ' + configuration_path)
        sys.exit(1)


if __name__ == '__main__':
    default_config = 'stable'
    if len(sys.argv) <= 1:
        print('You must pass witch configuration should be used. ', end='')
    else:
        default_config = sys.argv[1]

    print('Using [' + default_config + '] configuration.')

    update_recipes(default_config)
