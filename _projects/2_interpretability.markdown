---
layout: page
title: Deep Learning Interpretability 
description: For Software Engineering
img: /assets/img/proj1/asc_causal.png
importance: 1
category: interpretability

toc: 
    - name: Just a Section
---

This blog proposes a data science analysis that contributes to inform decision making in software engineering teams about traceability & retrieval of software artifacts. More specifically, the goal of this document is to articulate cases where the information captured in these artifacts might make it difficult for a developer to be able to effectively trace them to various locations in source code where they are implemented. For example, consider a situation where a development team needs to modify the XXX system based on an incoming new requirement. How should the developers proceed if we assume they are not familiar with all the components of the system or codebase? They probably will start by _tracing_ functionality between previous requirements  and the code by reading the associated documentation (e.g. code comments etc.). However, what if the descriptions in the requirements artifacts are _poorly written_?  Or what if certain areas of the source code are not completely documented or use obscure identifiers? Likely, the traceability process that a developer would undertake to understand the impact of the new requirement would be cumbersome and inefficient. We use information science and automated traceability to identify potential artifacts that might negatively contribute to the understandability of a given system. We briefly discuss an overview of our findings from this analysis below.


## Citation

```latex
@misc{palacio2023tracexplainer,
    title={Information Theory for Interpreting Software Traceability},
    author={David N. Palacio},
    year={2023},
    archivePrefix={arXiv},
    primaryClass={cs.SE}
}
```

