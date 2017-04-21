# NAME

AliTV filter - filters AliTV JSON files for postprocessing

# SYNOPSIS

    # Filter input file based on settings in JSON
    alitv-filter.pl --input in.json --output out.json

    # Filter input file based on settings in JSON in combination with
    # the command line settings
    alitv-filter.pl --input in.json --output out2.json --min-link-length 10000 --min-link-identity 90%

    # Filter input file based the command line settings and ignoring
    # JSON settings
    alitv-filter.pl --input in.json --output out3.json --ignore-json --min-link-length 10000 --min-link-identity 90%

# DESCRIPTION

The script filters AliTV JSON files for postprocessing.

# OPTIONS

- `--help|?|man`  Help

    Shows description of this programs, its usage, and its parameters/options.

- --input  Input file

    The name of the input file. Default value is input from STDIN which
    might be switched on by `--input -`.

- --output   Output file

    The name of the output file. Default value is output to STDOUT which
    might be switched on by `--output -`.

- `--min-link-identity`/`--max-lin-identity`   Minimum/Maximum identity for Links

    Specifies the minimal or maximum identity value for links. A float is
    expected. Numbers greater than 1 will be handled as percentage values,
    values up to 1.0 will be multiplied by 100 due to a fraction instead
    of a percentage value is assumed.

- `--min-link-length`/`--max-link-length`   Minimum/Maximum length for Links

    Specifies the minimal or maximum length for links. A integer is
    expected and specifies the length in nucleotids.

- `--min-seq-length`/`--max-seq-length`   Minimum/Maximum length for chromosomes

    Specifies the minimal or maximum length for chromosomes. A integer is
    expected and specifies the length in nucleotids.

- `--ignore-json` Ignore settings in JSON file

    Speciefies if the current settings from the JSON should be ignored,
    otherwise a combination of the limits inside the JSON file and the
    command line parameters will be used for filtering.

# AUTHOR

Frank Förster &lt;foersterfrank@gmx.de>

# SEE ALSO

- [AliTV-Demo-Page](https://alitvteam.github.io/AliTV/d3/AliTV.html)
- [AliTV-Website](https://alitvteam.github.io/AliTV/)
- [AliTV-Github-Page](https://github.com/AliTVTeam/AliTV)
