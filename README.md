# AliTV-Perl interface

[![AI-assisted](https://img.shields.io/badge/AI--assisted-since%20v2.0.0-orange.svg)](#ai-assistance)
[![Last release without AI](https://img.shields.io/badge/last%20release%20without%20AI-v1.0.6-blue.svg)](https://github.com/AliTVTeam/AliTV-perl-interface/releases/tag/v1.0.6)

> [!WARNING]
> **AI-assisted development since version 2.0.0**
>
> Starting with version 2.0.0, we use AI tools to help maintain AliTV-perl-interface.
> Right now we do not have the time to keep it up to date actively without AI support.
>
> - **What AI does at the moment:** it mainly helps us keep all dependencies up to date.
> - **What may come:** we do not rule out AI-assisted feature development in the future.
> - **Our promise:** we report openly what was done with AI support.
>   Every commit says what AI was used for, and every release lists the AI-assisted changes in [`Changes`](Changes).
>
> The last version developed without AI support is [v1.0.6](https://github.com/AliTVTeam/AliTV-perl-interface/releases/tag/v1.0.6).

## Build status

Latest build: [![Build Status](https://travis-ci.org/AliTVTeam/AliTV-perl-interface.svg?branch=master)](https://travis-ci.org/AliTVTeam/AliTV-perl-interface) [![Coverage Status](https://coveralls.io/repos/github/AliTVTeam/AliTV-perl-interface/badge.svg?branch=master)](https://coveralls.io/github/AliTVTeam/AliTV-perl-interface?branch=master)

## DESCRIPTION

This repository contains two helper scripts for [AliTV](https://github.com/AliTVTeam/AliTV):

- [A perl script `alitv.pl`](doc/alitv.md) to generate input files for [AliTV](https://github.com/AliTVTeam/AliTV).
- [A perl script `alitv-filter.pl`](doc/alitv-filter.md) to filter the json input files for [AliTV](https://github.com/AliTVTeam/AliTV).

⚠️ If your fasta file contains lowercase letters they will be treated as masked by `lastz`, see [issue#152](https://github.com/AliTVTeam/AliTV-perl-interface/issues/152)

## INSTALLATION

External Requirements:
 - perl
 - cpanm
 - [lastz](https://github.com/lastz/lastz)

Install with:
```
git clone https://github.com/AliTVTeam/AliTV-perl-interface
cpanm --installdeps .
```

## AI ASSISTANCE

Since version 2.0.0, AliTV-perl-interface is maintained with the help of AI tools.
The maintainers review every AI-assisted change before it is merged.
Each AI-assisted commit has a trailer that names the AI tool and says what it did, for example:
```
AI-Assisted: Claude Code drafted the dependency updates
```
If you prefer a version without any AI involvement, use [v1.0.6](https://github.com/AliTVTeam/AliTV-perl-interface/releases/tag/v1.0.6).

## CITE

An article about AliTV has been published in [PeerJ Computer Science](https://peerj.com/articles/cs-116/) [![DOI](https://img.shields.io/badge/DOI-10.7717%2Fpeerj--cs.116-blue.svg)](https://peerj.com/articles/cs-116/)
Please cite this article if you use AliTV-perl-interface in your project.
Additionally the software in any specific version can be cited via its zenodo doi:
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.597916.svg)](https://doi.org/10.5281/zenodo.597916)

## AUTHOR

- Frank Förster <foersterfrank@gmx.de>
- Markus J. Ankenbrand <markus.ankenbrand@uni-wuerzburg.de>

## SEE ALSO

- [AliTV-Demo-Page](https://alitvteam.github.io/AliTV/d3/AliTV.html)
- [AliTV-Website](https://alitvteam.github.io/AliTV/)
- [AliTV-Github-Page](https://github.com/AliTVTeam/AliTV)
