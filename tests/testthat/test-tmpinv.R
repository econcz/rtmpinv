test_that("tmpinv works for AP/TM on symmetric 10x10 matrix", {
  skip_if_not_installed("rclsp")
  
  set.seed(123)
  
  # smaller dimensions to avoid LAPACK instability
  m <- 10L
  p <- 10L
  n_cells <- m * p
  
  # deterministic, stable matrix (no rnorm)
  base <- matrix(seq_len(n_cells), nrow = m, ncol = p)
  X_true <- 0.5 * (base + t(base))
  
  # 10 percent known elements
  idx <- seq(1L, n_cells, length.out = max(1L, floor(0.1 * n_cells)))
  idx <- as.integer(idx)
  
  M     <- diag(n_cells)[idx, , drop = FALSE]
  b_row <- rowSums(X_true)
  b_col <- colSums(X_true)
  b_val <- matrix(as.numeric(X_true)[idx], ncol = 1L)
  
  result <- tmpinv(
    M = M, b_row = b_row, b_col = b_col, b_val = b_val,
    bounds = c(0, NA),
    symmetric = TRUE,
    r = 1L,
    alpha = 1.0
  )
  
  # structural tests
  expect_true(is.list(result))
  expect_true(is.matrix(result$x))
  expect_equal(dim(result$x), c(m, p))
  
  # stability metrics
  expect_true(is.finite(result$model$kappaC))
  expect_true(is.finite(result$model$kappaB))
  expect_true(is.finite(result$model$kappaA))
  expect_true(is.finite(result$model$nrmse))
  
  expect_true(all(is.finite(result$model$x_lower)))
  expect_true(all(is.finite(result$model$x_upper)))
  
  # minimal bootstrap test (small N to avoid CRAN timeouts)
  tt <- rclsp::ttest(
    result$model,
    sample_size = 10L,
    seed = 123L,
    distribution = rnorm,
    partial = TRUE
  )
  
  expect_true(is.list(tt))
  expect_gt(length(tt), 0L)
})

test_that("tmpinv works for reduced AP/TM on 20x20 zero-diagonal matrix", {
  skip_if_not_installed("rclsp")
  
  set.seed(123)
  
  # smaller dimensions for CRAN
  m <- 20L
  p <- 20L
  n_cells <- m * p
  
  # stable deterministic matrix
  base <- matrix(seq_len(n_cells), nrow = m, ncol = p)
  X_true <- abs(base)
  diag(X_true) <- 0L
  
  # 20 percent known elements
  idx <- seq(1L, n_cells, length.out = max(1L, floor(0.2 * n_cells)))
  idx <- as.integer(idx)
  
  M     <- diag(n_cells)[idx, , drop = FALSE]
  b_row <- rowSums(X_true)
  b_col <- colSums(X_true)
  b_val <- matrix(as.numeric(X_true)[idx], ncol = 1L)
  
  result <- tmpinv(
    M = M, b_row = b_row, b_col = b_col, b_val = b_val,
    zero_diagonal = TRUE,
    reduced = c(10L, 10L),   # smaller blocks → stable on Debian & Windows
    bounds = c(0, NA),
    r = 1L,
    alpha = 1.0
  )
  
  expect_true(is.list(result))
  expect_true(is.matrix(result$x))
  expect_equal(dim(result$x), c(m, p))
  
  # submodels
  expect_true(is.list(result$model))
  expect_gt(length(result$model), 0L)
  
  for (CLSP in result$model) {
    expect_true(is.finite(CLSP$kappaC))
    expect_true(is.finite(CLSP$kappaB))
    expect_true(is.finite(CLSP$kappaA))
    expect_true(is.finite(CLSP$nrmse))
    expect_true(all(is.finite(CLSP$x_lower)))
    expect_true(all(is.finite(CLSP$x_upper)))
    
    # block-level bootstrap test
    tt <- rclsp::ttest(
      CLSP,
      sample_size = 10L,
      seed = 123L,
      distribution = rnorm,
      partial = TRUE
    )
    
    expect_true(is.list(tt))
    expect_gt(length(tt), 0L)
  }
})
