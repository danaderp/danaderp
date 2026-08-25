---
layout: post
title: "Testing Theory: From Software Tests to Agent Assurance"
date: 2026-08-25
description: A systematic mapping of software testing, LLM-assisted testing, and agent evaluation research from 2020 to 2026.
tags: software-testing llm agents evaluation quality-assurance
categories: research
giscus_comments: true
related_posts: true
pretty_table: true
toc:
  sidebar: left
---

Software testing has always been an exercise in turning uncertainty into evidence. For conventional software, that evidence usually comes from executable checks: assertions, coverage, mutation scores, fault localization, and reproducible failures. Large language models (LLMs) and autonomous agents complicate this familiar picture. Their behavior is probabilistic, context-dependent, and spread across plans, tool calls, memory, external state, and human intervention.

This post maps research published or announced between 2020 and August 2026 across traditional software testing, LLM-assisted testing, agent testing, and agent evaluation. The central finding is not that conventional testing has become obsolete. It is that dependable agentic systems require a **layered assurance model** in which traditional tests, trajectory validation, statistical evaluation, safety analysis, and human oversight each answer a different question.

> Testing asks whether specified behavior holds and whether faults can be revealed. Evaluation asks how well a system performs across dimensions such as capability, reliability, cost, safety, and usability. Agent assurance needs both.

## How this mapping was built

The mapping prioritizes work from ICSE, FSE, ASE, ISSTA, TSE, TOSEM, EMSE, and STVR, supplemented by official publication pages and preprints for emerging agent research. It includes work on test generation, oracles, fuzzing, mutation analysis, regression testing, GUI and ML-system testing, trajectory validation, debugging, safety, benchmarking, and industrial quality assurance.

| Protocol element       | Applied rule                                                                                             |
| ---------------------- | -------------------------------------------------------------------------------------------------------- |
| Window                 | January 2020 through August 2026                                                                         |
| Primary venues         | ICSE, FSE, ASE, ISSTA, TSE, TOSEM, EMSE, and STVR                                                        |
| Complementary evidence | Official research pages and preprints for emerging agent work                                            |
| Inclusion              | A substantive contribution to testing, validation, debugging, benchmarking, or quality assurance         |
| Exclusion              | Pre-2020 work and pure code generation or repair without a testing or evaluation contribution            |
| Extraction             | Objective, subjects, metrics, study design, industrial involvement, findings, artifacts, and limitations |

This is a rapid systematic mapping rather than a publication-grade systematic literature review. When an abstract or venue page did not expose a field, I treated it as not reported instead of inferring it. Several 2026 records were still preprints, research reports, or forthcoming venue entries at the cutoff date, so their publication status should be rechecked before formal citation.

## The changing object of testing

Across the literature, the object under test expands in four stages:

1. **Deterministic software:** functions, classes, APIs, and system behavior.
2. **ML-enabled software:** data, models, pipelines, and behavior under distribution shift.
3. **LLM-assisted testing:** generated tests, assertions, inputs, and models that must themselves be validated.
4. **Agentic systems:** trajectories containing plans, tool calls, state transitions, side effects, recovery steps, and human decisions.

The progression matters because a final answer can be correct even when the path to it is unsafe, and a test suite can pass even when the implementation misses the actual requirement. Outcome-only evaluation hides both failure modes.

## Foundations that still matter

The traditional testing literature in this period reinforces several techniques that become even more important for probabilistic systems.

| Work                                                                                                                                                                                                                                                          | Evidence                                                       | Why it matters                                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [Defect Prediction Guided Search-Based Software Testing](https://doi.org/10.1145/3324884.3416612) (Perera et al., 2020)                                                                                                                                       | Defects4J and EvoSuite benchmark study                         | Learned predictions can focus a fixed testing budget, although results depend on benchmark and predictor validity. |
| [Metamorphic Robustness Testing](https://conf.researchr.org/track/icse-2020/icse-2020-papers) (Zhou et al., 2020)                                                                                                                                             | Empirical study of metamorphic violations                      | Metamorphic relations provide partial oracles when exact expected outputs are unavailable.                         |
| [MockSniffer](https://conf.researchr.org/track/ase-2020/ase-2020-papers) (Zhu et al., 2020)                                                                                                                                                                   | Tool and empirical study of unit tests                         | Testing quality depends on choices around isolation and mocking, not only on test quantity.                        |
| [TOGA: A Neural Method for Test Oracle Generation](https://doi.org/10.1145/3510003.3510141) (Dinella et al., 2022)                                                                                                                                            | Java test contexts and quantitative evaluation                 | Neural assertion generation helps with the oracle bottleneck, but generated oracles remain imperfect.              |
| [Testing Machine Learning Systems in Industry](https://www.microsoft.com/en-us/research/publication/testing-machine-learning-systems-in-industry-an-empirical-study/) (Li et al., 2022)                                                                       | 87 survey responses and 7 interviews                           | ML testing extends across data, models, pipelines, infrastructure, and changing production behavior.               |
| [A Study on the Lifecycle of Flaky Tests](https://www.microsoft.com/en-us/research/publication/a-study-on-the-lifecycle-of-flaky-tests/)                                                                                                                      | Repository study                                               | Flaky tests evolve over time and can corrupt the regression signal used for release decisions.                     |
| [Empirical Insights of Test Selection Metrics under Distribution Shifts](https://conf.researchr.org/details/fse-2026/fse-2026-research-papers/140/Empirical-Insights-of-Test-Selection-Metrics-under-Multiple-Testing-Objectives-and-Di) (Zhang et al., 2026) | 1,640 scenarios across 15 metrics, 13 models, and 3 modalities | A test-selection metric's value changes with the objective, modality, and type of distribution shift.              |
| [Dataset of Reproducible Flaky-Test Failures](https://conf.researchr.org/track/issta-2026/issta-2026-research-papers) (Rafi et al., 2026)                                                                                                                     | Curated open-source failures                                   | Reproducible datasets make flaky-test detection and repair claims easier to compare.                               |
| [AsyncLeakBench](https://conf.researchr.org/track/issta-2026/issta-2026-research-papers) (Kim et al., 2026)                                                                                                                                                   | Benchmark of open-source Java projects                         | Curated failure corpora remain essential for evaluating specialized detection techniques.                          |

Three ideas carry directly into agent assurance. First, partial oracles are useful when exact outputs are unavailable. Second, benchmark construction is part of the scientific contribution. Third, an unreliable test signal can be as damaging as a faulty implementation.

## LLMs as test generators

The strongest pattern in LLM-assisted testing is **hybridization**. Successful systems rarely trust an LLM as the only generator, executor, and judge. Instead, the model proposes candidates while deterministic analysis, execution, mutation, or repair loops decide what survives.

| Work                                                                                                                                                                                            | Testing strategy                                                            | Main lesson                                                                                                   |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| [CodaMOSA](https://github.com/LLM-Testing/LLM4SoftwareTesting) (2023)                                                                                                                           | Combines LLM suggestions with search-based software testing                 | Model suggestions help search escape coverage plateaus; feedback from execution remains essential.            |
| [LLMs Are Few-Shot Testers](https://github.com/LLM-Testing/LLM4SoftwareTesting) (2023)                                                                                                          | Generates bug-reproduction tests from reports and examples                  | LLMs can reproduce bugs, but generated tests require compilation and execution checks.                        |
| [MuTAP](https://arxiv.org/abs/2308.16557) (Dakhel et al., 2023)                                                                                                                                 | Uses surviving mutants to guide prompting                                   | Mutation feedback targets weaknesses that raw coverage can miss.                                              |
| [An Empirical Evaluation of LLM Unit Test Generation](https://ieeexplore.ieee.org/document/10329992) (Schaefer et al., 2024)                                                                    | Large empirical benchmark of generated unit tests                           | Useful tests coexist with compilation failures, weak assertions, and missed edge cases.                       |
| [Fuzz4All](https://software-lab.org/publications/icse2024_Fuzz4All.pdf) (Xia et al., 2024)                                                                                                      | Uses LLMs as cross-language fuzzing engines                                 | Broad semantic input generation can expose real bugs, but inference cost and reproducibility remain concerns. |
| [Make LLM a Testing Expert](https://github.com/LLM-Testing/LLM4SoftwareTesting) (2024)                                                                                                          | Functionality-aware mobile GUI exploration                                  | Semantic reasoning improves exploration beyond coordinate- or widget-driven strategies.                       |
| [Testing the Limits](https://github.com/LLM-Testing/LLM4SoftwareTesting) (2024)                                                                                                                 | Generates unusual text inputs for mobile applications                       | LLMs are effective semantic input generators for edge cases and crash discovery.                              |
| [SymPrompt](https://2024.esec-fse.org/details/fse-2024-research-papers/90) (Ryan et al., 2024)                                                                                                  | Aligns prompts with symbolic path information                               | Program structure produces more valid tests and better coverage than fixed prompting alone.                   |
| [TestGen-LLM](https://arxiv.org/abs/2402.09171) (Alshahwan et al., 2024)                                                                                                                        | Generates test improvements behind build, execution, and coverage gates     | Industrial adoption depends on deterministic quality filters and developer acceptance.                        |
| [ChatUniTest](https://arxiv.org/abs/2305.04764) (Chen et al., 2024)                                                                                                                             | Generation, validation, and repair loop                                     | Adaptive context and iterative repair improve the executability and coverage of generated tests.              |
| [LLM-Based Test-Driven Interactive Code Generation](https://www.microsoft.com/en-us/research/project/trusted-ai-assisted-programming/publications/) (Fakhoury et al., 2024)                     | Structures human-LLM interaction around tests                               | Tests help coordinate iterative development, although outcomes remain sensitive to tasks and users.           |
| [Eywa](https://www.microsoft.com/en-us/research/publication/eywa-automating-model-based-testing-using-llms/) (2025)                                                                             | Extracts protocol models from specifications and executes model-based tests | LLMs can lower the expertise barrier for model construction while executable checking supplies evidence.      |
| [CASCADE](https://conf.researchr.org/details/fse-2026/fse-2026-research-papers/131/CASCADE-Detecting-Inconsistencies-between-Code-and-Documentation-with-Automatic-Test) (Kiecker et al., 2026) | Cross-checks generated tests against code and documentation                 | Multiple evidence sources reduce false positives in inconsistency detection.                                  |
| [Validating LLM-Generated SQL Through Metamorphic Prompting](https://conf.researchr.org/track/fse-2026/fse-2026-research-papers) (Lin et al., 2026)                                             | Applies metamorphic properties where exact SQL outputs are unavailable      | Classical oracle strategies transfer naturally to generated artifacts.                                        |

These systems suggest a robust division of labor:

- Use an LLM to generate semantically rich candidates.
- Use program analysis or retrieval to ground those candidates.
- Compile and execute before accepting them.
- Measure fault revelation, not only line coverage.
- Repair failures through feedback loops.
- Keep the release gate independent from the generator whenever possible.

## From output checks to trajectory tests

An agent does more than return text. It observes an environment, creates or revises a plan, selects tools, passes arguments, modifies state, responds to failures, and may delegate work. Agent testing therefore shifts attention from a single output to a sequence of consequential actions.

| Work                                                                                                                                                                                                                | Target                             | Contribution                                                                                                         |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| [Testing Practices in Open Source AI Agent Frameworks](https://arxiv.org/abs/2509.19185) (Hasan et al., 2025/2026)                                                                                                  | 39 frameworks and 439 applications | Finds that tests concentrate on deterministic tools and workflows while prompts and plan bodies remain under-tested. |
| [Learning Correct Behavior from Examples](https://www.microsoft.com/en-us/research/publication/learning-correct-behavior-from-examples-validating-sequential-execution-in-autonomous-agents/) (Sharma et al., 2026) | Passing execution traces           | Learns acceptable sequential behavior from a small set of successful trajectories.                                   |
| [AgentChaos](https://conf.researchr.org/track/ase-2026/ase-2026-research-track) (Tan et al., 2026)                                                                                                                  | Fault-injected agent systems       | Adapts chaos engineering to evaluate resilience and recovery in agent workflows.                                     |
| [AgentInspect](https://conf.researchr.org/track/issta-2026/issta-2026-research-papers) (Manke et al., 2026)                                                                                                         | Agent trajectories                 | Diagnoses behavioral failures rather than assigning only an end-to-end score.                                        |
| [AgentBreaker](https://conf.researchr.org/track/issta-2026/issta-2026-research-papers) (Son et al., 2026)                                                                                                           | Web-agent environments             | Tests context-aware indirect prompt injection and the risks created by untrusted observations.                       |
| [Dynamic Temporal Reasoning Test Generation](https://conf.researchr.org/track/issta-2026/issta-2026-research-papers) (Zhou et al., 2026)                                                                            | Generated temporal tasks           | Produces difficulty-controlled tests that reduce dependence on static benchmark items.                               |
| [AgentRx](https://www.microsoft.com/en-us/research/blog/systematic-debugging-for-ai-agents-introducing-the-agentrx-framework/) (2026)                                                                               | 115 annotated failed trajectories  | Combines executable constraints, evidence logs, and grounded judging for auditable root-cause analysis.              |
| [ScenGen](https://arxiv.org/abs/2506.05079) (2025/2026)                                                                                                                                                             | Mobile application scenarios       | Coordinates observer, decider, executor, supervisor, and recorder roles around scenario memory.                      |

A practical trajectory test can assert more than task completion. It can check whether:

- only permitted tools were called;
- tool arguments satisfied policy and schema constraints;
- required approvals occurred before consequential actions;
- state transitions preserved invariants;
- failures triggered bounded retries or safe recovery;
- sensitive observations were excluded from memory;
- side effects matched the user's intent; and
- the final result remained traceable to evidence.

This is closer to protocol conformance and runtime verification than to conventional response grading.

## Evaluation beyond the final answer

Benchmarking research is also becoming more realistic. New evaluations introduce repeated runs, dynamic tasks, long trajectories, concurrent workloads, human collaboration, adversarial context, and explicit cost trade-offs.

| Work                                                                                                                                                                  | Evaluation focus                                        | Main lesson                                                                                    |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| [Magentic-One](https://www.microsoft.com/en-us/research/articles/magentic-one-a-generalist-multi-agent-system-for-solving-complex-tasks/) (Fourney et al., 2024)      | Multi-step task completion with repeated, isolated runs | Agent evaluation needs reproducible environments and repeated measurements.                    |
| [Agent-as-a-Judge](https://arxiv.org/abs/2410.10934) (2024)                                                                                                           | Outcome and process judging                             | Process-aware judging adds information but still needs calibration and independent validation. |
| [Magentic-UI](https://www.microsoft.com/en-us/research/wp-content/uploads/2025/07/magentic-ui-report.pdf) (2025)                                                      | Web tasks, usability, interaction, and safety           | Human collaboration and security resilience are part of system quality.                        |
| [UI-E2I-Synth](https://www.microsoft.com/en-us/research/articles/ui-e2i-synth-realistic-and-challenging-ui-grounding-benchmark-for-computer-use-agents/) (2025)       | Realistic UI grounding                                  | Harder synthetic tasks challenge inflated scores on existing UI benchmarks.                    |
| [Fara-7B and WebTailBench](https://www.microsoft.com/en-us/research/blog/fara-7b-an-efficient-agentic-model-for-computer-use/) (2025/2026)                            | Web trajectories and verifier outcomes                  | Alignment, rubric, and multimodal verifiers can filter synthetic demonstrations.               |
| [CORPGEN](https://www.microsoft.com/en-us/research/blog/corpgen-advances-ai-agents-for-real-work/) (2026)                                                             | Up to 46 interdependent workplace tasks                 | Performance under sustained task load can degrade in ways single-task scores do not reveal.    |
| [Atropos](https://conf.researchr.org/track/issta-2026/issta-2026-research-papers) (Kim and Yoo, 2026)                                                                 | Accuracy-cost trade-offs                                | Early termination and model switching make evaluation efficiency an explicit design concern.   |
| [AttnCompress](https://conf.researchr.org/track/issta-2026/issta-2026-research-papers) (Zeng et al., 2026)                                                            | Long-trajectory context and cost                        | Context management affects both performance and the economics of evaluation.                   |
| [Building to the Test](https://www.microsoft.com/en-us/research/publication/building-to-the-test-coding-agents-deliver-what-you-check-not-what-you-requested/) (2026) | Test passing versus requirement satisfaction            | Visible checks can reward benchmark gaming without establishing semantic correctness.          |

The last result is especially important. A benchmark is not a neutral observer: it defines what an agent optimizes. If the benchmark checks only visible tests, then passing those tests may become a substitute for understanding the requirement. Hidden behavioral checks, independent specifications, and adversarial semantic tests are therefore matters of construct validity, not merely benchmark difficulty.

## What industry evidence emphasizes

Industrial studies are relatively scarce, but they are unusually consistent about release discipline.

| Study                                                                                                                                                          | Setting                            | Operational lesson                                                                                                                                     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [TestGen-LLM at Meta](https://arxiv.org/abs/2402.09171) (2024)                                                                                                 | Production test improvement        | Generated suggestions become useful when build, execution, coverage, reliability, and review gates filter them.                                        |
| [Testing ML Systems in Industry](https://www.microsoft.com/en-us/research/publication/testing-machine-learning-systems-in-industry-an-empirical-study/) (2022) | Multiple IT companies              | Quality failures span organizational processes as well as data, model, and software components.                                                        |
| [RL for Runtime Verification of Software Tests](https://conf.researchr.org/track/issta-2026/issta-2026-research-papers) (Kim et al., 2026)                     | Experience-report setting          | Learning-assisted verification must be judged on operational speed, effectiveness, and constraints.                                                    |
| Operationalizing LLM Evaluation at Scale (Jha et al., 2026)                                                                                                    | Internal enterprise-agent platform | Evaluation becomes sustainable when it is automated, configuration-driven, and integrated with release processes; this evidence was not peer reviewed. |

The common architecture separates **probabilistic generation** from **deterministic acceptance**. Models may propose tests, plans, diagnoses, or fixes, but production systems rely on executable gates and accountable review to decide what ships.

## Surveys that organize the field

Several reviews provide broader taxonomies and useful entry points.

| Review                                                                                                                                                                           | Scope                                             | Takeaway                                                                                                       |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [Software Testing With LLMs: Survey, Landscape, and Vision](https://ieeexplore.ieee.org/abstract/document/10440574) (Wang et al., 2024)                                          | 102-paper living bibliography                     | Maps generation, oracles, fuzzing, debugging, and repair across the emerging field.                            |
| [LLMs for Unit Test Generation: Achievements and Road Ahead](https://arxiv.org/html/2511.21382v1) (Chu et al., 2025)                                                             | 115 publications                                  | Prompt engineering and repair loops dominate, while fault detection and benchmark standardization remain weak. |
| [Review of LLMs for Automated Test Case Generation](https://www.mdpi.com/2504-4990/7/3/97) (Celik and Mahmoud, 2025)                                                             | Automated test generation studies                 | Coverage gains coexist with recurring compilation, correctness, and consistency limitations.                   |
| [LLM-Based Multi-Agent Systems for Software Engineering](https://arxiv.org/html/2404.04834v3) (He, Treude, and Lo, 2024/2025)                                                    | Multi-agent systems across the software lifecycle | Trust and evaluation remain central gaps despite broad application coverage.                                   |
| [Survey of LLM-Based Agent Evaluation](https://arxiv.org/abs/2503.16416) (2025)                                                                                                  | Agent benchmarks and frameworks                   | Safety, robustness, fine-grained diagnosis, and cost are underdeveloped dimensions.                            |
| [Large Language Model-Brained GUI Agents: A Survey](https://www.microsoft.com/en-us/research/publication/large-language-model-brained-gui-agents-a-survey/) (Zhang et al., 2025) | GUI automation and computer-use agents            | Connects agent architecture with rapidly evolving grounding and interaction benchmarks.                        |

## Six trends across the evidence

### 1. Hybrid testing dominates

LLMs are paired with search-based testing, execution repair, mutation testing, model-based testing, metamorphic relations, and deterministic filters. The model is most useful as a candidate generator or orchestrator, not as the sole oracle.

### 2. Assurance is becoming trajectory-oriented

For agents, plans, tool calls, state changes, recovery behavior, and side effects are first-class test targets. Teams need trace schemas, invariants, and replayable environments before they can test these properties consistently.

### 3. Benchmarks are becoming more realistic

Distribution shifts, changing interfaces, concurrent workplace tasks, and adversarial observations increasingly appear in evaluation designs. Static, single-turn success rates are weak evidence for deployment readiness.

### 4. Statistical evaluation is unavoidable

LLM and agent outcomes vary across runs. Reports should identify the model and version, prompts, sampling settings, run counts, variance, uncertainty, and failure distribution. A single successful demonstration is not a reliability result.

### 5. Industrial systems emphasize gates

Production reports filter generated artifacts through compilation, execution, coverage, reliability, security, and human acceptance. This pattern turns a probabilistic proposal into auditable release evidence.

### 6. Human oversight is part of system quality

Human co-planning, monitoring, approval, and review are not external to the evaluated system. Useful metrics include intervention workload, missed failures, time to detection, override effectiveness, and calibration of trust.

## A layered assurance model

The literature supports five complementary layers:

| Layer                           | What it checks                                                    | Representative evidence                                               |
| ------------------------------- | ----------------------------------------------------------------- | --------------------------------------------------------------------- |
| Deterministic component testing | Tool functions, APIs, schemas, permissions, and state transitions | Unit, integration, mutation, fuzz, and regression tests               |
| Generated-artifact validation   | Compilability, executability, assertions, and fault revelation    | TestGen-LLM, ChatUniTest, MuTAP, SymPrompt                            |
| Trajectory testing              | Plans, tool sequence, recovery, memory, and side effects          | Trace models, runtime constraints, AgentChaos, AgentRx                |
| Statistical evaluation          | Capability, reliability, variance, cost, and robustness           | Repeated benchmark runs, dynamic tasks, workload tests                |
| Human and production validation | Usability, oversight, incidents, and release acceptance           | User studies, field studies, deployment gates, longitudinal telemetry |

No layer substitutes for another. Unit tests cannot establish whether an agent followed an appropriate plan. An LLM judge cannot prove a tool call was authorized. A high benchmark score cannot show that behavior remains stable after a model update. Human approval cannot compensate for missing telemetry.

## Open research problems

### Independent oracles

When a generator and judge share a model family, training distribution, or prompt context, their errors may be correlated. Research should compare executable, metamorphic, differential, expert, and independent-model oracles, both separately and in ensembles.

### Prompt and memory regression

Open-source projects test deterministic tools more often than prompts, retrieval corpora, tool descriptions, or memory policies. These artifacts need versioning, behavioral fixtures, adversarial cases, and release gates of their own.

### Agent mutation testing

Agent-specific mutation operators remain immature. Useful operators could alter prompts, permissions, tool schemas, delegation rules, observations, memory, retry policies, and recovery logic. Their value should be validated against real incidents rather than assumed from analogy with code mutation.

### Longitudinal reliability

Most studies use short benchmark runs. Deployment evidence must account for model upgrades, prompt drift, accumulated memory, repeated users, tool changes, and rare incidents over time.

### Causal failure attribution

A failed trajectory may implicate reasoning, context, memory, a tool, the environment, or their interaction. Controlled interventions, counterfactual replay, causal graphs, and falsification tests could turn post-hoc explanations into stronger diagnoses.

### Multi-agent emergent risk

Safe components do not guarantee safe interactions. Multi-agent assurance needs communication mutation, delegation checks, cascading-failure analysis, collusion and deadlock scenarios, and network-level red teaming.

### Reporting consistency

Prompts, model versions, artifacts, costs, run counts, and threats to validity are still reported unevenly. A minimum evaluation sheet would make results easier to reproduce and compare.

## Research priorities

| Priority | Research question                                                                         | Suggested design                                                                            |
| -------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| P1       | Which oracle combinations best predict real agent failures?                               | A multi-oracle benchmark with expert adjudication and prospective production validation     |
| P1       | Does trajectory coverage add fault-detection value beyond task success?                   | Seeded agent mutations evaluated against explicit trajectory-coverage criteria              |
| P1       | How should nondeterministic regression gates balance false alarms and missed regressions? | Sequential statistical tests with repeated runs and simulated release decisions             |
| P2       | Are failures caused by reasoning, tools, context, memory, or environment?                 | Controlled interventions over instrumented, replayable trajectories                         |
| P2       | How are agent-testing methods adopted in practice?                                        | Longitudinal field studies combining repository telemetry, interviews, and incident reports |
| P3       | What adequacy criteria are valid for multi-agent systems?                                 | Validation of interaction, delegation, recovery, communication, and side-effect coverage    |

## A practical evaluation checklist

For teams building agentic software today, the research translates into a concrete baseline:

- Define the requirement independently of the tests used to score it.
- Test deterministic tools and permission boundaries conventionally.
- Record structured, replayable trajectories.
- Assert invariants over actions and state, not only final answers.
- Evaluate with repeated runs and report uncertainty.
- Include malformed inputs, tool failures, stale context, and adversarial observations.
- Measure fault revelation and requirement satisfaction alongside coverage and task success.
- Keep generator and release oracle as independent as practical.
- Version prompts, tool descriptions, retrieval data, memory policy, and model configuration.
- Track latency, token use, monetary cost, and human-review burden.
- Require approval before irreversible or high-impact actions.
- Monitor production drift and feed incidents back into regression suites.

## Conclusion

The strongest trend from 2020 to 2026 is a shift from testing deterministic outputs toward assuring probabilistic behavior. Traditional techniques remain the foundation: mutation testing reveals weak suites, metamorphic testing supplies partial oracles, fuzzing explores unexpected inputs, model-based testing checks protocols, and regression testing protects known behavior.

What changes for agents is the unit of evidence. A dependable evaluation must account for the entire trajectory: what the agent observed, how it planned, which tools it called, what state it changed, how it recovered, and where a human intervened. Capability benchmarks then sit alongside, rather than replace, executable tests and production evidence.

The result is a broader definition of quality assurance: **generate with models, verify with independent evidence, evaluate statistically, and govern consequential behavior throughout its lifecycle.**
