---
name: dbt Wizard Notebook Migration
description: Convert Databricks SQL and PySpark notebooks into governed dbt models by discovering upstream references, model boundaries, naming conventions, configurations, tests, documentation, and reusable project patterns from the connected dbt project. Use when migrating one or more Databricks notebooks into an existing dbt project or asking dbt Wizard to create dbt models from notebook logic.
---

# Instructions

Convert Databricks notebooks into dbt project assets using the existing repository as the source of truth. Do not require the user to identify upstream model names, source names, model layers, or test conventions when the project can reveal them.

## Establish context

1. Confirm the notebook path or repository location. Prefer a Git-connected repository or project checkout over pasted notebook content.
2. Inspect the dbt project before proposing code:
   * `dbt_project.yml`, `packages.yml` or `dependencies.yml`, and project macros.
   * Existing model directories and layer conventions such as staging, intermediate, marts, or domain-specific equivalents.
   * Nearby SQL models, Python models, YAML files, source definitions, tests, contracts, tags, grants, and materialization settings.
   * Existing references to the notebook’s tables, columns, functions, parameters, and business terms.
3. Treat notebook table names as candidates. Resolve each candidate from project context:
   * Use `ref()` when the relation is an existing dbt model or should become one in the migration.
   * Use `source()` when the relation is a raw or externally owned object represented by an existing source definition.
   * Add or extend source YAML only when the project convention supports it and the relation is genuinely external.
   * If multiple candidates exist, compare schemas, naming, lineage, and usage before choosing; report unresolved ambiguity instead of guessing.
4. Inspect upstream and downstream dependencies before changing model boundaries. Preserve existing project conventions over generic dbt patterns.

## Read and classify the notebook

1. Read all notebook cells, including SQL, PySpark, Python helpers, parameters, comments, temporary views, table writes, and orchestration code.
2. Separate relational transformation logic from procedural control flow, diagnostics, display code, data movement, and environment-specific setup.
3. Preserve meaningful semantics: grain, joins, filters, aggregations, null behavior, deduplication, ordering requirements, incremental windows, and write behavior.
4. Flag logic that is implicit, incomplete, environment-dependent, or not reproducible from the notebook alone.

## Choose the dbt decomposition

Choose model boundaries from the existing project’s conventions and dependency graph. Do not assume that every notebook cell becomes a model and do not force the entire notebook into one model.

* Keep simple, single-purpose transformations together when that matches nearby project models.
* Split distinct staging, cleansing, intermediate, aggregation, and mart steps when the project uses those layers or when separation improves dependency visibility and reuse.
* Convert repeated calculations into references to existing models or project-standard macros rather than duplicating logic.
* Represent notebook orchestration as dbt dependencies and model selection, not as nested notebook calls or procedural sequencing.
* Keep the final model grain explicit in its description and validation plan.

Before writing files, summarize the proposed mapping from notebook steps to dbt models and identify any assumption that could change the result.

## Translate SQL and PySpark

### SQL notebooks

* Convert table-creation statements, `DROP TABLE`, `saveAsTable`, and manual write operations into dbt model SQL with `config()`.
* Preserve the project’s materialization convention. If the notebook creates a Delta table, use the Databricks adapter’s project-standard Delta configuration without adding physical optimizations that were not requested.
* Replace hard-coded database, catalog, schema, or table references with discovered `ref()` and `source()` calls. Avoid embedding environment-specific relation names in model SQL.
* Move reusable environment or business parameters into existing vars, environment variables, macros, or model configs according to project conventions.

### PySpark and mixed-language notebooks

* Prefer SQL models for relational logic when the project and adapter can express the transformation clearly in SQL.
* Use dbt Python models only when the project already uses them or the transformation genuinely requires Python/PySpark APIs supported by the configured Databricks adapter.
* Preserve DataFrame semantics, joins, aggregations, filters, and write behavior when translating to SQL or Python.
* Do not silently replace unsupported UDFs, libraries, filesystem operations, streaming behavior, or procedural side effects. Isolate them, propose an equivalent, or report them as migration items.
* Keep Python dependencies and runtime requirements aligned with existing project configuration; do not invent package installation steps.

## Generate documentation and tests

1. Follow the project’s existing YAML layout, naming, descriptions, tags, test severity, contracts, and documentation style.
2. Add a model description and descriptions for every new model and output column. Carry forward useful notebook comments, but do not present comments as confirmed business rules.
3. Infer tests from:
   * Existing tests on related models and columns.
   * Upstream uniqueness, nullability, accepted values, relationship, and contract patterns.
   * The model grain and explicit transformations in the notebook.
4. Add appropriate generic, unit, or singular tests using project conventions. Common candidates include `not_null`, `unique`, `relationships`, accepted values, and grain tests, but do not invent allowed values or constraints.
5. When a test depends on an unconfirmed business rule, infer the most consistent project pattern, mark the assumption clearly, and set warning severity or leave it as a review item when that is the project convention.
6. Do not weaken or remove existing tests to make the migration pass.

## Validate the migration

Validate in a development environment before any production action.

* Run the project’s standard parse, compile, build, and test commands for the selected models.
* Confirm every `ref()` and `source()` resolves and the generated DAG reflects the intended dependency order.
* Compare output columns, data types, row counts, grain, null behavior, and representative results against the notebook where access is available.
* Check incremental behavior, relation naming, Delta configuration, permissions, and environment-specific settings.
* Inspect generated documentation and lineage.
* Do not claim equivalence when the notebook contains unsupported or ambiguous behavior; list the gap and the required human decision.

## Return a complete result

Return or create:

1. The generated dbt model SQL and, when needed, Python model files.
2. YAML documentation and tests following the existing project structure.
3. Any macros, sources, seeds, or configuration changes that are genuinely required.
4. A concise notebook-to-model mapping showing how each meaningful step was handled.
5. A list of discovered upstream references and why each became a `ref()` or `source()`.
6. Validation results, assumptions, unresolved items, and recommended human review points.

Do not hard-code example model names from a prior task. Discover all model and source references from the connected project each time.
