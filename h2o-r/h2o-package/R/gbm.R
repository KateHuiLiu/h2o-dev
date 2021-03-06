h2o.gbm <- function(x, y, data, key="",
                    #AUTOGENERATED params
                    loss,
                    ntrees,
                    max_depth,
                    min_rows,
                    learn_rate,
                    nbins,
                    group_split,
                    variable_importance,
                    validation_frame,
                    balance_classes,
                    max_after_balance_size,
                    seed,
                    # group_split
                    nfolds = 0)
{
  # Set Input Parameters for GBM
  parms = list()

  if(data %i% "ASTNode") delete = TRUE && invisible(nrow(data)) else delete = FALSE

  # Verify Training Frame
  args <- .verify_dataxy(data, x, y)

  parms <- .addStringParm(parms, k = "training_frame", v = data@key)
  parms$response_column = args$y
  parms$ignored_columns = args$x_ignore

  if(!is.character(key)) stop("key must be of class character")
  if(nchar(key) > 0 && regexpr("^[a-zA-Z_][a-zA-Z0-9_.]*$", key)[1] == -1)
    stop("key must match the regular expression '^[a-zA-Z_][a-zA-Z0-9_.]*$'")
  parms$destination_key = key

  if(!is.numeric(nfolds)) stop("nfolds must be numeric")
  if(nfolds == 1) stop("nfolds cannot be 1")
  if(!missing(validation_frame) && class(validation_frame) != "H2OParsedData") stop("validation must be an H2O parsed dataset")

  if(missing(validation_frame) && nfolds == 0) {
    validation_frame = new ("H2OParsedData", key = as.character(NA))
    parms$validation_frame = validation_frame@key
    #parms$n_folds = nfolds
  } else if(missing(validation_frame) && nfolds >= 2) {
    validation_frame = new("H2OParsedData", key = as.character(NA))
    #parms$n_folds = nfolds
  } else if(!missing(validation_frame) && nfolds == 0)
    parms$validation_frame = validation_frame@key
  else stop("Cannot set both validation and nfolds at the same time")

  # ----- AUTOGENERATED PARAMETERS BEGIN -----
  parms = .addStringParm(parms, k = "loss", v = loss)
  parms = .addIntParm(parms, k = "ntrees", v = ntrees )
  parms = .addIntParm(parms, k = "max_depth", v = max_depth )
  parms = .addIntParm(parms, k = "min_rows", v = min_rows )
  parms = .addFloatParm(parms, k = "learn_rate", v = learn_rate)
  parms = .addIntParm(parms, k = "nbins", v = nbins )
  parms = .addBooleanParm(parms, k = "variable_importance", v = variable_importance)
  parms = .addLongParm(parms, k="seed", v=seed)
  parms = .addLongParm(parms, k = "balance_classes", v = balance_classes )
  parms = .addLongParm(parms, k = "max_after_balance_size", v = max_after_balance_size )
  #parms = .addBooleanParm(parms, k = "group_split", v = group_split )

  model_params <- .h2o.__remoteSend(data@h2o, method = "POST", '2/GBM.json', .params = parms)
  res <- .h2o.__remoteSend(data@h2o, method = "POST", h2o.__MODEL_BUILDERS('gbm'), .params = parms)

  #parms$h2o <- data@h2o
  parms$h2o <- data@h2o

  job_key <- res$key$name
  dest_key <- res$jobs[[1]]$dest$name
  .h2o.__waitOnJob(data@h2o, job_key)
  res_model <- list()
  res_model$params <- model_params
  new("H2OGBMModel", h2o = data@h2o, key = dest_key, data = data, model = res_model, valid = new("H2OParsedData", h2o=data@h2o, key="NA"), xval = list())
}