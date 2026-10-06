---
layout: post
title: "How to Create an AI Benchmark"
date: 2026-10-06
description: A practical guide for software developers and applied scientists. Build the metric, methodology, and testbeds from scratch.
tags: benchmarking
categories: research
giscus_comments: true
related_posts: true
pretty_table: true
toc:
  sidebar: left
---

A practical guide for software developers and applied scientists. Build the metric, methodology, and testbeds from scratch.

> David N. Palacio · Blog draft

## Start with a question, not a dataset

To create an AI benchmark, first define what you want to measure. Then build the rules and data that support that measurement.

A collection of test cases is not enough. A score is not enough. You need a clear connection between the action, score, method, and evidence.

This guide shows software developers and applied scientists how to build that connection from scratch. It applies to models, agents, and complete AI systems.

The same process can support code generation, root cause analysis, evidence retrieval, and other AI capabilities.

> **The central idea**
>
> Create a benchmark as an evaluation contract with three parts: a metric, a methodology, and testbeds.
>
> The metric defines the score. The methodology defines its interpretation. The testbeds provide the cases and expected outcomes.
>

## Define the capability and its property

A capability is an action that an AI system can perform under stated conditions. A property is a quality of that action or its result.

A capability can be a specific skill, an inference action, or an emergent behavior. An emergent behavior appears through the system’s combined operation.

Name the observable action in each case. Do not use broad labels, such as intelligence, without a specific task definition.

| Capability: the action | Property: the quality | Possible metric |
| --- | --- | --- |
| Infer an incident’s root cause. | Correctness of the diagnosis. | Root-cause accuracy. |
| Retrieve evidence for a question. | Coverage of relevant evidence. | Recall of relevant items. |
| Generate an answer from evidence. | Agreement with that evidence. | A defined faithfulness score. |
| Generate a program. | Functional correctness. | Pass rate on specified execution tests. |

Retrieval-Augmented Generation (RAG) is a system method. It combines retrieval with answer generation. Define the actions and properties within that method.

For example, evaluate evidence retrieval and answer faithfulness separately. One combined score can hide which part failed.

A metric measures a selected property. It does not establish every property of the system.

## The three parts of a benchmark

| Part | Question it answers | What you must specify |
| --- | --- | --- |
| Metric | What number describes the property? | Scoring rule, scale, units, direction, and failure handling. |
| Methodology | What does that number estimate? | Population, estimand, sampling, uncertainty, and causal analysis when applicable. |
| Testbeds | Which cases support the estimate? | Inputs, expected outcomes, metadata, partitions, and generation records. |

A metric converts an observed result into a number. Examples include accuracy, precision, recall, retrieval rate, and similarity.

A methodology specifies how to calculate and interpret results. It connects the metric to a defined statistical question.

A testbed contains evaluation cases and their expected outcomes. It also records where the cases came from and how you checked them.

Create these parts together. If the testbeds change, the population can change. If the scoring rule changes, the meaning can change.

## A running example: diagnosis of service incidents

Suppose you want a benchmark for agents that identify the root cause of a service failure. Use a controlled service simulation.

Each case contains one verified fault and a fixed evidence window. The evidence can include logs, measurements, and service relationships.

- Capability: Infer the incident’s root cause from the supplied evidence.
- Property: Correctness of the selected cause.
- Input: An evidence package and the allowed cause identifiers.
- Expected output: One cause identifier.
- Scope: Single-fault incidents from the declared simulation and fault catalog.

This is an example design, not a report of an experiment. Its purpose is to show how the construction steps fit together.

The example does not establish diagnostic ability on production incidents. A separate population and testbed would be necessary for that claim.

## Build the benchmark in eight steps

### 1. Write the benchmark specification

State the question that the benchmark must answer. Define the action, property, input, expected output, and operating conditions.

Define the target population: the cases to which your result should apply. Define the evaluation unit: one independently scored case.

Also state what the benchmark does not cover. Exclusions are part of the specification, not details to hide later.

> **Example specification**
>
> Measure root-cause accuracy for single-fault incidents from the specified simulation, with fixed evidence windows and allowed cause identifiers.
>
> One incident is one evaluation unit. Multiple log messages from the same incident are not independent cases.
>

List the fault categories, service configurations, workloads, and evidence rules that define this population. Do not call it all service incidents.

Keep the benchmark independent of one vendor or model where possible. Define observable inputs and outputs instead of private implementation details.

Expected artifact: A short capability specification with the purpose, scope, population, and task contract.

### 2. Design the metric and scorer

Choose a primary metric that matches the property. Add secondary metrics only when they answer a separate, stated question.

For the example, use an exact match between the returned cause identifier and the verified expected identifier.

```text
m(case) = 1 if predicted_cause_id = expected_cause_id; otherwise 0
```

Observed accuracy is the number of correct cases divided by the number of scored cases. A larger value means better diagnosis accuracy.

Specify the scoring rules before you create final test results:

- Define the output format and allowed identifiers.
- Define any normalization or accepted equivalent answers.
- Score invalid answers and task timeouts under a fixed rule.
- For this example, assign zero to wrong, invalid, or absent answers.
- Distinguish task failure from infrastructure failure.
- Define retry and missing-observation rules for infrastructure failures.

Do not remove difficult cases or failed answers to improve the score. Keep infrastructure gaps visible in the result.

If people or an AI judge assign scores, publish the rubric and judge configuration. Check agreement against independently reviewed examples.

A similarity score is not a correctness score. A retrieval score is not an answer-quality score. Keep these meanings separate.

Expected artifact: A metric specification, an executable scorer, and checks for known correct, incorrect, and invalid outputs.

### 3. Define the methodology and estimand

An estimand is the exact quantity that you want to estimate. It connects a score to a population and execution conditions.

For the example, define expected diagnosis accuracy over the declared incident population:

```text
θ(system) = E_target[m(case)]
```

Here, θ is the target accuracy. The expectation uses the declared incident distribution and execution protocol.

Choose the distribution deliberately. For this example, give each declared fault category equal weight. Do not treat those weights as production frequencies.

An estimator is the calculation that estimates the estimand from sampled cases. Calculate each category’s mean, then average those means with equal weights.

Specify the statistical properties that you will report. They can include the mean, variation across runs, and results for pre-defined groups.

Record the following design choices:

- Sampling frame: The eligible cases or generator configurations.
- Sampling strategy: How you select cases and balance groups.
- Sample size: The uncertainty target and the information used to select it.
- Repeated runs: How you measure variation in system outputs.
- Aggregation: How you combine cases, groups, and repeated outputs.
- Uncertainty: The confidence level, interval method, and assumptions.

Use validation data to plan the sample size. Do not increase or decrease it after you see favorable final results.

For the example, sample randomly within fault categories. Record selection probabilities and use weights if the sampling design requires them.

Plan an uncertainty estimate, such as a 95% confidence interval. Choose an interval method that matches the sampling design.

Related cases require group-aware analysis. For example, a cluster bootstrap can resample independent scenario families instead of individual log records.

Keep related cases together in each resample. Preserve the category weights and sampling design. Specify how repeated outputs enter the analysis.

Record the resample count and seed. Confirm that the design includes enough independent groups for the selected interval method.

State whether the interval covers case sampling, output variation, or both. An interval does not guarantee transfer to another workload.

If an interval is not appropriate, state the reason. For example, the benchmark might describe a complete finite testbed with deterministic outputs.

### Add causal analysis when the question requires it

A capability estimate asks how well a system performs. A causal estimate asks what a specified change causes.

Root cause diagnosis is the task in this example. That task does not make every comparison between agents a causal study.

If you want the effect of a system change, define the treatment and comparison condition. Keep that question separate from absolute accuracy.

```text
Δ = E_target[m_changed − m_reference]
```

For a controlled comparison, evaluate both conditions on the same cases. Randomize execution order and prevent carryover between sessions.

State exactly what changes. If prompts, tools, and model versions all change, the effect concerns that complete package.

For observational data, justify a causal model and adjustment strategy. A confounder is a pre-treatment cause of treatment choice and outcome.

Correlation alone does not identify a confounder. Do not automatically adjust for a variable that the treatment itself changes.

Record assumptions, diagnostic checks, and limits. Do not describe an unexplained score difference as proof of causation.

Expected artifact: An evaluation protocol with estimands, sampling, aggregation, uncertainty, and any causal analysis plan.

### 4. Build a repeatable testbed pipeline

Choose the data origin. You can collect cases, generate synthetic cases, or combine both with recorded origin labels.

Define a repeatable sequence: obtain data, transform it, assign expected outcomes, check quality, and create task records.

Record sources, source versions, collection dates, selection rules, tools, and generator settings. Save prompts and seeds when generation uses them.

Define preconditions. A precondition states what must be true before collection or generation.

For the example, require a healthy baseline, a specified workload, an allowed fault, and a fixed observation procedure.

Apply one fault in the test environment. Collect only the evidence that the task permits.

Define postconditions. A postcondition states what must be true about the generated case and its expected outcome.

For the example, confirm the intended failure and verify its connection to the fault. Check recovery after you remove the fault.

Record deviations and uncertain labels. An injected fault is not automatic proof of an incident’s root cause.

Assign the expected cause identifier only after the checks pass. Reject or separately classify cases with unresolved competing causes.

Keep fault-injection notes and expected identifiers out of the agent’s evidence package. They belong in the hidden evaluation record.

For collected incidents, document how reviewers established the expected cause. Record disagreements and accepted alternatives.

For synthetic cases, verify the generated labels independently. A generator’s proposed answer is not sufficient evidence by itself.

Expected artifact: A data-generation recipe with source records, preconditions, postconditions, labels, and quality checks.

### 5. Add metadata and partitions

Create a metadata file that defines every testbed field. Include its meaning, type, units, allowed values, source, and missing-value rule.

| Field | Type | Purpose |
| --- | --- | --- |
| case_id | Text | Stable identifier for one evaluation case. |
| group_id | Text | Identifier for related cases or a common scenario family. |
| input | Structured object | Only the evidence that the evaluated system can access. |
| expected_output | Structured object | Verified answer, accepted alternatives, or evaluation rubric. |
| origin | Category | Collected, synthetic, or mixed. |
| source_version | Text | Source snapshot or generator version. |
| generation_config | Structured object or reference | Recipe, settings, prompts, seeds, and selection rules. |
| condition_checks | Structured object | Results of the precondition and postcondition checks. |
| label_status | Category | Verified, disputed, or excluded under the declared policy. |
| case_features | Structured object | Pre-defined factors such as evidence size or fault category. |
| partition | Category | Training, validation, or test; training is optional. |

Separate validation and test cases when you tune the system or benchmark. Add a training partition if the task requires one.

Use validation cases for prompt choices, scorer development, and pilot checks. Reserve test cases for final estimates under frozen rules.

Split related cases as groups. A group can be one incident, document family, repository, or simulation scenario.

For the example, keep each scenario family within one partition. Check that all required fault categories remain covered.

Detect duplicates and cross-partition overlap. Record the grouping rule, split assignments, and seed.

Do not use a different random row split when related cases share the same source. That split can expose task-specific information.

Document known training overlap and unknown overlap. Synthetic origin alone does not prove independence from training data.

If you omit a partition, explain why. Keep final test labels separate from system development.

Expected artifact: Versioned case files, partition assignments, a metadata schema, and a documented label policy.

### 6. Implement the evaluation harness and run a pilot

An evaluation harness gives inputs to a system, collects outputs, and applies the scorer. It must enforce the methodology.

Define the allowed tools, context, time limits, output format, and resource limits. Apply the same protocol to every eligible system.

Save raw inputs, outputs, settings, per-case scores, failures, and timing records. Record system versions separately from the benchmark version.

Use a small validation pilot before the final release. Check the benchmark itself, not only the AI system.

- Confirm that known correct and incorrect outputs receive the expected scores.
- Check invalid outputs, task timeouts, and service errors.
- Inspect missing fields, duplicates, ambiguous labels, and label leakage.
- Check that the metric responds to the intended property.
- Verify the sampling and aggregation calculations.
- Confirm that the harness exposes only permitted input fields.

Add a simple reference baseline. For diagnosis, it could select a cause from validation frequencies without reading incident evidence.

Do not report a baseline score before you run it. Its purpose is to make the task and scorer easier to check.

Fix defects with validation data. Finalize the metric, methodology, and testbeds before final system comparisons.

Expected artifact: A runnable harness, validation checks, a reference baseline, and a pilot quality report.

### 7. Document, freeze, and publish the benchmark

Package the three main artifacts as one release. Include the supporting files needed to reproduce their definitions and execution.

| Artifact | Suggested files | Minimum content |
| --- | --- | --- |
| Metric | metric.md; scorer; scorer checks | Property, formula, units, direction, normalization, and failure rules. |
| Methodology | methodology.md; evaluation configuration; analysis procedure | Task contract, estimands, sampling, uncertainty, aggregation, and causal assumptions. |
| Testbeds | Case files; metadata schema; generation recipe; partition assignments | Inputs, labels, provenance, preconditions, postconditions, and quality checks. |
| Release support | benchmark-card.md; manifest; change history | Purpose, limits, component versions, hashes, and reproduction instructions. |

A file hash identifies the exact file content. Save hashes and component versions in the release manifest.

Keep evaluated-system settings and run results separate from the fixed benchmark definition. One benchmark can support many evaluation runs.

Create a short benchmark card with these headings:

- Purpose, intended users, and supported decisions.
- Capability, property, task contract, and population.
- Metric definitions and known measurement limits.
- Estimands, sampling, aggregation, uncertainty, and causal assumptions.
- Data origin, generation, labels, metadata, and partitions.
- Coverage gaps, possible training overlap, and data-use restrictions.
- Release version, component hashes, and execution instructions.
- Change history and limits of comparison with earlier releases.

For incident data, remove secrets and restrict sensitive records before distribution. State access and licensing conditions.

Publish the contract and its limits together. If test labels are public, explain the risk of later test-set exposure.

Expected artifact: A frozen release that another evaluator can inspect and run under the same rules.

### 8. Version and evolve the benchmark

Version the metric, methodology, and testbeds together. Also record each component’s version in the manifest.

Use a major.minor.patch format, such as 1.0.0. The following is one proposed policy; document the policy you adopt.

| Version change | Rule | Example |
| --- | --- | --- |
| Major | A change can alter the primary result or its meaning. | Change canonical cases, labels, scoring, weights, task rules, or the target population. |
| Minor | An addition leaves the existing primary evaluation unchanged. | Add optional metadata or a separately scored supplemental testbed. |
| Patch | A correction leaves scores and estimates unchanged. | Correct documentation without changing execution. |

Under this policy, a label correction or scorer fix requires a major release if it can change results.

A new model or agent configuration creates a new run. A changed fixed evaluation contract creates a new benchmark release.

Keep old releases, labels, splits, and hashes available. Do not silently replace cases or change a scorer under the same version.

Use validation failures, new workload needs, and coverage gaps to propose changes. Do not tune the benchmark to favor one system.

1. State the gap that the new release must address.
2. Revise the specification and affected artifacts.
3. Check the revised design on validation data.
4. Prepare independent final test cases.
5. Freeze the new contract.
6. Evaluate the same reference systems on old and new releases.
7. Publish the changes, both results, and comparison limits.

Reference systems help explain release differences. They do not make scores from different benchmark versions interchangeable.

Compare systems within the same release whenever possible. If developers tune on exposed test cases, use new cases for final claims.

A new version number does not remove data exposure. Record that history and revise the testbed when necessary.

Expected artifact: A release policy, preserved snapshots, and a change history with reasons and comparability limits.

## Start small, but make the contract complete

Your first benchmark can target one capability, one property, and a narrow population. Small scope is acceptable. An undefined scope is not.

Start with one primary metric, one documented methodology, and a checked testbed. Add partitions when tuning makes them necessary.

Expand only when the new cases or measurements answer a stated question. More data do not repair an unclear estimand.

> **The construction sequence**
>
> Define the capability and property. Design the metric. Specify the methodology. Build and label the testbeds.
>
> Check the complete pipeline. Document the contract. Freeze the release. Evolve it with explicit versions.
>

A useful benchmark does more than produce a number. It defines what that number means, which evidence supports it, and where the claim stops.

## Inspiration and language notes

Inspiration: “Benchmarking Causal Study to Interpret Large Language Models for Source Code,” Daniel Rodriguez-Cardenas, David N. Palacio, Dipin Khati, Henry Burke, and Denys Poshyvanyk, 2023. arXiv:2308.12415v1. [Read the paper](https://arxiv.org/abs/2308.12415)

Galeras connects curated testbeds, recorded features, and causal analysis (Sections III–IV). Those ideas inspire this guide; the workflow and incident example are general proposals.

---

> General benchmark-construction guidance. The running example is a proposed design, not an experimental result.