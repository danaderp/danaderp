---
layout: page
title: Information Science 
description: For Software Traceability & Retrieval
img: /assets/img/proj1/infoscience.png
importance: 1
category: interpretability
---

This blog proposes a data science analysis that contributes to inform decision making in software engineering teams about traceability & retrieval of software artifacts. More specifically, the goal of this document is to articulate cases where the information captured in these artifacts might make it difficult for a developer to be able to effectively trace them to various locations in source code where they are implemented. For example, consider a situation where a development team needs to modify the XXX system based on an incoming new requirement. How should the developers proceed if we assume they are not familiar with all the components of the system or codebase? They probably will start by _tracing_ functionality between previous requirements  and the code by reading the associated documentation (e.g. code comments etc.). However, what if the descriptions in the requirements artifacts are _poorly written_?  Or what if certain areas of the source code are not completely documented or use obscure identifiers? Likely, the traceability process that a developer would undertake to understand the impact of the new requirement would be cumbersome and inefficient. We use information science and automated traceability to identify potential artifacts that might negatively contribute to the understandability of a given system. We briefly discuss an overview of our findings from this analysis below.

For the XXX system we found that oftentimes, pull request comments and the associated source code often contain different information. That is, it is very likely that the pull request comments and source code and its comments are describing disparate information. This is based on an information theoretic analysis that carries a 95% confidence which signals that pull requests contain [3.42 ± 0.02] bits and source code contains [5.91 ±  0.01] bits of information respectively. Such an imbalance of information should be avoided as it suggests that the code changes might not accurately capture the information content of the pull request. What could _high quality_ mean in this context? A well-written pull request is an artifact that a software engineer can easily trace on the source code documentation. This report lists concrete examples in the last section where potential links suffer from imbalance. This current automated analysis can be used to detect these instances of information mismatch, and our planned follow up work will attempt to make semantically meaningful suggestions for revisions to improve the documentation.

In a sample of 21,312 potential trace links (i.e., from pull request comments to python files), the information loss went from about 2.68 up to 2.72 bits among artifacts for a 95% confidence interval. This result implies that, on average, 84.11% of the information content in the pull request comments cannot be traced back to the source code or it's comments. This _information loss_ is likely occurring due to mismatches the source artifacts have tokens that cannot be found in the target artifacts. Additionally, the _information noise_ (or content that should not be in the source code) went from about 0.21 up to 0.22 bits, which indicates that no suspicious information was found in the code. 

In general, we recommend examining these imbalanced links, or information discrepancies, between pull requests and source code in order to design a refactoring strategy oriented toward reducing the loss and augmenting the mutual information among the software documentation. Bear in mind that the level of mutual information is around 3.21 bits with an error of 0.02 for a confidence of 95%. An ideal range of mutual information may vary according to the system. However, managers should avoid lower values in the mutual information range. Our full report below contains additional information as well as the technical details of our techniques.


## Introduction

    ---
    layout: page
    title: project
    description: a project with a background image
    img: /assets/img/12.jpg
    ---

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/1.jpg' | relative_url }}" alt="" title="example image"/>
    </div>
    <div class="col-sm mt-3 mt-md-0">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/3.jpg' | relative_url }}" alt="" title="example image"/>
    </div>
    <div class="col-sm mt-3 mt-md-0">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/5.jpg' | relative_url }}" alt="" title="example image"/>
    </div>
</div>
<div class="caption">
    Caption photos easily. On the left, a road goes through a tunnel. Middle, leaves artistically fall in a hipster photoshoot. Right, in another hipster photoshoot, a lumberjack grasps a handful of pine needles.
</div>
<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/5.jpg' | relative_url }}" alt="" title="example image"/>
    </div>
</div>
<div class="caption">
    This image can also have a caption. It's like magic.
</div>

You can also put regular text between your rows of images.
Say you wanted to write a little bit about your project before you posted the rest of the images.
You describe how you toiled, sweated, *bled* for your project, and then... you reveal it's glory in the next row of images.


<div class="row justify-content-sm-center">
    <div class="col-sm-8 mt-3 mt-md-0">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/6.jpg' | relative_url }}" alt="" title="example image"/>
    </div>
    <div class="col-sm-4 mt-3 mt-md-0">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/11.jpg' | relative_url }}" alt="" title="example image"/>
    </div>
</div>
<div class="caption">
    You can also have artistically styled 2/3 + 1/3 images, like these.
</div>


The code is simple.
Just wrap your images with `<div class="col-sm">` and place them inside `<div class="row">` (read more about the <a href="https://getbootstrap.com/docs/4.4/layout/grid/" target="_blank">Bootstrap Grid</a> system).
To make images responsive, add `img-fluid` class to each; for rounded corners and shadows use `rounded` and `z-depth-1` classes.
Here's the code for the last row of images above:

```html
<div class="row justify-content-sm-center">
    <div class="col-sm-8 mt-3 mt-md-0">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/6.jpg' | relative_url }}" alt="" title="example image"/>
    </div>
    <div class="col-sm-4 mt-3 mt-md-0">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/11.jpg' | relative_url }}" alt="" title="example image"/>
    </div>
</div>
```
