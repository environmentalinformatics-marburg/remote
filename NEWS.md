# remote 1.2.2.9000 (2025-03-26)

#### ✨ features and improvements

#### 🐛 bug fixes

#### 💬 documentation etc

#### 🍬 miscellaneous


# remote 1.2.2 (2023-06-05)

#### ✨ features and improvements

  * `readEot()`: imports previously created EOT* files back into R. For that
    purpose, file 'remote_eot_locations.csv' (created from `eot()` or
    `writeEot()`) now includes pixel IDs of all leading modes.
  * `predict()`: features a proper 'filename' argument in addition to '...',
    thus allowing the user to specify further options passed to `raster::calc()`
    and, at the same time, enabling layer-by-layer storage of the resulting
    `Raster*` images.

#### 🐛 bug fixes

  * Fixes warning message related to missing 'expl.var' object.
  * Minor documentation updates.

#### 🍬 miscellaneous

  * Adds a `NEWS.md` file to track changes to the package.
