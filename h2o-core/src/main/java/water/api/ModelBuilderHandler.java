package water.api;

import hex.ModelBuilder;
import hex.schemas.ModelBuilderSchema;
import water.H2O;
import water.Job;

abstract public class ModelBuilderHandler<B extends ModelBuilder, S extends ModelBuilderSchema<B,S,P>, P extends ModelParametersSchema> extends Handler<B, S> {
  @Override protected int min_ver() { return 2; }
  @Override protected int max_ver() { return Integer.MAX_VALUE; }

  /**
   * Create a model by launching a ModelBuilder algo.  If the model
   * parameters pass validation this returns a Job schema; if not it
   * returns a ModelParametersSchema containing the validation messages.
   */
  @SuppressWarnings("unused") // called through reflection by RequestServer
  public Schema train(int version, B builder) {
    if (builder.error_count() > 0) {
      S builder_schema = (S) builder.schema().fillFromImpl(builder);
      return builder_schema;
    }

    Job j = builder.trainModel();
    return JobsHandler.jobToSchemaHelper(version, j);
  }

  @SuppressWarnings("unused") // called through reflection by RequestServer
  public S validate_parameters(int version, B builder) {
    S builder_schema = (S) builder.schema().fillFromImpl(builder);
    return builder_schema;
  }

  abstract protected S schema(int version);
  /*
  Children must override, because we can't create a new instance from the type parameter.  :-(
  @Override protected ModelBuilderSchema schema(int version) {
    switch (version) {
    case 2:   return new ModelBuilderV2();
    default:  throw H2O.fail("Bad version for ModelBuilder schema: " + version);
    }
  }
  */

  // Need to stub this because it's required by H2OCountedCompleter:
  @Override public void compute2() { throw H2O.fail(); }
}
