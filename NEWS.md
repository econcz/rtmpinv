# rtmpinv 1.1.0

## Changes
* Updated the minimum R version to R 4.3 to match CVXR 1.8.x requirements.
* Synchronized the package with `rclsp` 1.1.0.

# rtmpinv 1.0.0

## Changes in CLSP
* Synchronized the package with `rclsp` 1.0.0.
* Added support for the `cond_tolerance` argument, passed through to the
  underlying CLSP solver.

## Bug fixes
* Improved row-wise matrix vectorization and reconstruction to match NumPy
  row-major behavior where required.
* Improved handling of bound-constrained iterative refinement.
* Added support for upper and lower bounds in reduced models.

# rtmpinv 0.3.0

## Bug fixes
* Updated CVXR integration for CVXR 1.8.x compatibility.

# rtmpinv 0.2.0

## New Features
* Developed full support for upper/lower bounds in reduced models.
* Fixed zero-diagonal constraint handling.
