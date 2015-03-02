# EzBake Configuration, python edition

## Versioning
For snapshot builds we will use a dev pre-release tag with git describe info

```bash
python setup.py egg_info --tag-build ".dev-$(git describe --tags 2>/dev/null)"
```

## Distribution
For snapshot builds, use rotate to only keep the last 5 versions:

```bash
$ setup.py bdist_egg rotate -m.egg -k5
```
