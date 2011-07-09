# Genia Tagger Patches #

[Genia Tagger](http://www-tsujii.is.s.u-tokyo.ac.jp/GENIA/tagger/) long been a
go-to tool at Tsujii Laborator, these patches are applicable for the
Genia Tagger 3.0.1 April 16th 2007 release.

These patches were produced when I needed to do large-scale parsing of PubMed,
with the patches and some parallelisation I managed to do roughly 20'000'000
files in under six hours.

**Warning:** While these patches have been tested live and they have been
given a fair round of testing the author was by no means proficient in C++ at
the time and leave no guarantees to the number of idioms blatantly ignored
and/or replaced by C idioms.

## Changelog ##

* `-f` flag to interpret stdin as file paths, this enables you to read a vast
    amount of files without reloading the dictionaries
* `-l` to disable long line warnings and `-q` to silence status output of
    loading models and dictionaries, keeps `stderr` clean for detecting errors
    when embedding inside shell scripts
* `-n` disables NER, this gives a significant speed-up if you are not
    interested in the NER output
* `-o` is to be used with `-f` and creates output files (`${INPUT_PATH}.gtag`)
    instead of printing to `stdout`, this makes it very easy to do large
    batches of input and output files
* Some minor changes to make it more difficult for a user to get unexpected
    output for a given input
