---
layout: distill
title: ASTxplainer
description: Explaining Large Language Models for Code Using Syntax Structures
giscus_comments: true
date: 2023-10-16

authors:
  - name: David A. Nader
    url: "https://en.wikipedia.org/wiki/Albert_Einstein"
    affiliations:
      name: Semeru, W&M

bibliography: 2023-10-16-astxplainer.bib

# Optionally, you can add a table of contents to your post.
# NOTES:
#   - make sure that TOC names match the actual section names
#     for hyperlinks within the post to work correctly.
#   - we may want to automate TOC generation in the future using
#     jekyll-toc plugin (https://github.com/toshimaru/jekyll-toc).
toc:
  - name: Abstract
    # if a section has subsections, you can add them as follows:
    # subsections:
    #   - name: Example Child Subsection 1
    #   - name: Example Child Subsection 2
  - name: Introduction
  - name: Background & Related Work
  - name: The ASC-Eval Component
  - name: Results
  - name: Citation

# Below is an example of injecting additional post-specific styles.
# If you use this post as a template, delete this _styles block.
_styles: >
  .fake-img {
    background: #bbb;
    border: 1px solid rgba(0, 0, 0, 0.1);
    box-shadow: 0 0px 4px rgba(0, 0, 0, 0.1);
    margin-bottom: 12px;
  }
  .fake-img p {
    font-family: monospace;
    color: white;
    text-align: left;
    margin: 12px 0;
    text-align: center;
    font-size: 16px;
  }

---

## Abstract

Large Language Models (LLMs) for code are a family of high-parameter, transformer-based neural networks pre-trained on massive datasets of both natural and programming languages. These models are rapidly being employed in commercial AI-based developer tools, such as GitHub CoPilot. However, measuring and explaining their effectiveness on programming tasks is a challenging proposition, given their size and complexity. We believe that the methods for _evaluating_ and _explaining_ LLMs for code are inextricably linked. That is, in order to explain a model's predictions, they must be reliably mapped to fine-grained, understandable concepts that helps developers to detect how good syntactic elements that are being predicted by LLMs. Once this mapping is achieved, new methods for detailed model evaluations are possible. However, most current explainability techniques and evaluation benchmarks focus on model robustness or individual task performance, as opposed to interpreting model predictions.

To this end, this paper introduces ASTxplainer, an explainability method specific to LLMs for code that enables both new methods for LLM evaluation and AST visualizations of LLM predictions that aid end-users in understanding model predictions. At its core, ASTxplainer provides an automated method for aligning token predictions with AST nodes, by extracting and aggregating normalized model logits within AST structures.

To demonstrate the practical benefit of ASTxplainer, we illustrate the insights that our framework can provide by performing an empirical evaluation on 12 popular LLMs for code using a curated dataset of the most popular GitHub projects. Additionally, we perform a user study examining the usefulness of an ASTxplainer-derived visualization of model predictions aimed at enabling model users to explain predictions. The results of these studies illustrate the potential for ASTxplainer to provide insights into LLM effectiveness, and aid end-users in understanding predictions.

## Introduction
The advent and proliferation of online open-source code repositories and rapid advancements in transformer-based neural large language models LLMs have served as a catalyst for the advancement of automated Software Engineering (SE) tools with rapidly advancing effectiveness. \llms for code have demonstrated considerable proficiency across a diverse array of generative SE tasks, inclusive of, but not restricted to, code completion <d-cite key="Raychev2014CodeCW"></d-cite>\cite{Raychev2014CodeCW,MSR-Completion}, program repair \cite{Chen2019sequencer,ahmad_unified_2021}, and test case generation <d-cite key="Watson:ICSE2"></d-cite>. Moreover, these advancements are rapidly being introduced into commercial developer tools such as GitHub CoPilot <d-cite key="github_copilot"></d-cite> and Replit's Ghostwriter <d-cite key="ghostwriter"></d-cite>. 

However, the sheer complexity and size that enable the often surprising effectiveness of \llms for code is a double-edged sword. That is, while these attributes enable \llms to capture important patterns in code that allow them to be applied to a range of programming tasks, effectively \textit{explaining} and \textit{evaluating} the capabilities of these models is a challenging proposition --- they effectively function as ``black boxes'' that derive predictions from exceedingly complex internal model mechanics. Current research in both designing \llms for code and in applying them to programming tasks typically makes use of existing benchmarks (\eg CodeSearchNet~\cite{husain2019codesearchnet}, or HumanEval~\cite{chen_evaluating_2021}) and metrics that have been adapted from the field of natural language processing (NLP) such as accuracy, BLEU, METEOR, and ROUGE, as well as more recent metrics further tailored for code such as CodeBLEU~\cite{ren_codebleu_2020}. However, recent work has illustrated the limitations of benchmarks such as HumanEval~\cite{liu2023code}, and there has been growing criticism of automated metrics within the NLP community~\cite{molnar2019interpret,Kim2018InterpretabilityTCAV,wan_what_2022,liu_reliability_2023}. These deficiencies largely stem from the fact that such benchmarks and metrics are often targeted at evaluating functional or syntactic correctness of generated code or task performance, but are not able to \textit{explain} model predictions or capabilities in an interpretable manner.

Methods for \textit{evaluating} and \textit{explaining} \llms for code are inextricably linked to one another. An informative evaluation requires some degree of explainability of model predictions, such that model behavior can be understood at a fine-grained level. However, the fundamental challenge in achieving explainability of \llms for code lies in establishing a reliable mapping mechanism that can bridge the gap between a given model's predictions and human-understandable programming language (PL) concepts that can aid in explaining the model's decisions. As such, designing both effective evaluations and interpretability techniques for \llms of code requires that one first establish this conceptual mapping.

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        <p align="center">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/blog_astxplainer/fig_1_generative_process_astxplainer.png' | relative_url }}" alt="centered image" title="example image"/>
        </p>
    </div>
</div>
<div class="caption">
    Figure 3. The evaluativa and explainability method is composed of ASC-EVal, ASC-Causal, and ASC-Viz.
</div>

To overcome the challenges in explaining and evaluating \llms for code we propose a novel method for enabling a reliable conceptual mapping of \llm predictions to PL concepts, called \astxplainer, which collects and aggregates \llm token predictions into a construct that we call Abstract Syntax Concepts (\asc), derived from Abstract Syntax Trees (ASTs). By explicitly mapping model predictions to code structure, \astxplainer provides a fine-grained methodology for examining \textit{how} models perform relative to programming language concepts, and can help model end-users reason about \textit{why} an \llm may have made a certain set of predictions. \astxplainer's mapping of model predictions to \ascs enables two new types of evaluations for \llms of code, and one novel interpretability technique that visualizes model \ascs to aid end users (\ie developers using \llms to auto-complete code) in understanding \llm predictions. Fig.~\ref{fig:astxplainer} illustrates these three main components of \astxplainer.

The first evaluation technique, called \asceval is able to estimate the structural performance of a predicted syntax element in order to measure the uncertainty of the downstream code generative process (e.g., for code completion). The second evaluation technique called \asccausal, is capable of generating causal explanations that link these structural performance values with canonical model performance (i.e., Cross-Entropy Loss). Finally, \ascviz implements a practical interpretability technique by visualizing model \llm prediction uncertainty, organized into AST structures, aiding end-users in understanding the reliability of model predictions in practice. We evaluate \asceval and \asccausal through a large-scale, comprehensive empirical study that evaluates 12 popular \llms on a novel dataset of $\approx$ 10 million tokens that are exclusive of the model's training data. Furthermore, to evaluate the effectiveness of \ascviz, we conduct a user study examining the utility of multiple visualizations in aiding developers to understand and explaining model predictions. The results of our empirical study lead to novel insights regarding the performance of \llms for code, and user study illustrates the promising utility of \ascviz. 

## Background & Related Work

\astxplainer is an evaluative and explainability approach to quantify the prediction uncertainty of \llms for code. \llms are the result of scaling up billions of parameters for context-aware word representations from pre-trained models\cite{zhao_survey_2023}. This section defines and formalizes the basic elements of our approach. We provide a definition of \llms and how to evaluate them, the definition of Abstract Syntax Trees (ASTs) and how they were employed for probing, and finally, the explainability methods for \llms. 

Our research focused on \llms because of their outstanding performance on code-based generative tasks. While other representations exist, such as graph-based models~\cite{allamanis2018learning,Allamanis19}, we focus our discussion on sequence-based representations for simplicity. The goal of sequence-based models is to statistically learn a representation of a software artifact (\eg snippet, comments, or test cases). We refer to SE-specific sequence-based data as a software corpus $\mathcal{S}$. Given the sequential nature of $\mathcal{S}$, we can decompose $\mathcal{S}$ into a desired granularity of tokens, words, or sub-words \cite{Karampatsis2019} by using a transformation function $\Gamma(\mathcal{S})= w_1,...,w_I$ (\ie \textit{tokenizers}). This transformation function is a tokenization method for converting a software corpus into a sequence of discrete objects $w_i$  for $1 \leqslant i \leqslant I$. Note that $w_i \in V$, where the vocabulary $V$ is a finite set.

Given this definition, a statistical language model is a probability distribution $P$ over a fixed granularity of sequences of software corpora $\mathcal{S}$. We can factorize the joint distribution over the $i-$dimension as: $P(\mathcal{S}) = P(w_1,...,w_I) = \prod_{i = 1}^{I} P(w_i | w_{<i})$. Due to the discrete nature of the data, the expression $P(w_i | w_{<i})$ can be estimated using a classifier. The classifier, in our particular case, is a LLM \cite{Bengio2003AModel}. Hence, rather than using \textit{n}-grams or Markov Models to approximate $P(w_i | w_{<i})$ \cite{Karampatsis2020Open-VocabularyAbstract}, it is convenient to use a latent model $P(w_i | w_{<i} ) \approx P(w_i | h_i )$, where $h_i$ is known as a \textit{hidden state} that embeds the sequence information from past observations up to the time step $i$.

Depending on \textit{how} the sequence is processed, the hidden state $h_i$ can be computed using either \textit{Encoder-Only}, \textit{Encoder-Decoder}, or \textit{Decoder-Only} architectures according to the \textit{transformers'} layers ~\cite{vaswani2017transformers}. One popular bidirectional objective function used widely in representation learning is \textit{masked language} modeling \cite{devlin_bert_2019}. This function aims to predict masked text pieces based on the surrounding context. CodeBERT \cite{feng_codebert_2020}, CuBERT (345M) \cite{kanade_learning_2020} CodeRoBERTa  \cite{lin_span_2022}, and GraphCodeBERT \cite{guo_graphcodebert_2021} are examples of \textit{Encoder-Only} models for code. In programming contexts, these methods provide useful representations of code sequences for downstream tasks such as code classification, clone and defect detection. CodeT5 \cite{wang_codet5_2021} and PLBART \cite{ahmad_unified_2021} are examples of \textit{Encoder-Decoder} models. These models encode an input sequence and, then, this encoded sequence is decoded with a different architecture. Encoder-Decoder models are trained with the goal of reconstructing masked input sequences \cite{lewis_bart_2019}. Additionally, they have been employed for SE tasks such as code summarization, and code generation using masks\cite{wang_codet5_2021}. Finally, \textit{Decoder-Only} models predict the probability of a token given a preceding sequence. CodeGPT \cite{lu_codexglue_2021}, CodeParrot \cite{codeparrot}, GPT-Neo \cite{black_sid_2021_5297715}, GPT-J \cite{gpt-j}, Codex \cite{openai_codex}, GPT-NeoX \cite{GPTNeoX}, and Google's left-to-right decoder-only Transformer language models \cite{vaswani2017transformers,austin2021program} are examples of \textit{Decoder-Only} models for code. 

Although our proposed approach \astxplainer was designed to be compatible with either type of \llms, this paper concentrated on \textit{Decoder-Only} models due to their popularity for code-based generative tasks \cite{xu_systematic_2022}. These models share a common property: \textit{the ability to connect previously processed information to a present task, such as using an initial sequence of tokens to predict new code tokens}. The resulting auto-completed sequence should be coherent with respect to the context of the initial sequence. This property is known as the ability to model \textit{long-range dependencies}~\cite{karpathy2015understand}. 

_Definition 1:_\textbf{Decoder-Only Transformers.} Decoder-Only models update the hidden state $h_i = f(h_{i-1}, w_{<i})$ using past inputs $w_{<i}$ and a previous hidden state $h_{i-1}$. In other words, these models function in a feed-forward manner that predicts future values from historical values directly. \llms trained on source code have the ability to generate tokens or sub-words given a history. Hence, decoder-only models are employed as generative models $\hat{w_i} \backsim P(w_i | w_{<i} ) = \sigma(y)_i = \frac{e^{y_{w_i}}}{\Sigma_j e^{y_j}}$. 

In the previous approximation, the predicted token $w_i$ is \textit{conditioned} by the previous information. The term $y_j$ represents the \textit{non-normalized log-probabilities} for each output token $j$. We extracted and normalized these \textbf{log-probabilities} from the last layer of \llms to estimate the \textbf{Next-token Predictions} (\ntp) in \astxplainer (see Sec.\ref{sec:approach}). This estimation relies on the softmax function. The softmax $\sigma_i$ returns a distribution over predicted output classes, in this case, the classes are each token in the previously introduced vocabulary $V$. It is expected that the predictions contained in $\sigma_i$ are influenced by previous inputs of the sequence $w_{<i}$. 

\textit{Probing} is a supervised analysis to determine which type of parameters (\eg input code snippets, tokenization process, number of hidden layers, and model size) influence the learning process in machine learning models \cite{troshin_probing_2022}. The purpose of probing is to assess whether hidden representations of machine learning models (\ie \llms) encode specific linguistic properties such as syntactic structures of programming languages. For example, Lopez \etal \cite{lopez_ast-probe_2022} trained a linear classifier to show that code syntactic structures are encoded in pre-trained models in the form of Abstract Syntax Trees (ASTs). Lopez \etal's approach demonstrates that the middle layers of pre-trained models contain ASTs' information\cite{lopez_ast-probe_2022}.

Nonetheless, instead of proposing another syntax probe, our approach \astxplainer adapts AST information to evaluate and explain \llms (see Sec.~\ref{sec:approach}). ASTs are defined as a formal representation of syntactical structures built upon linguistic elements of PLs. ASTs are formed according to the production rules defined in Context Free Grammar (CFGs). More precisely, production rules are functions that combine terminal and non-terminal nodes into statements. Terminal nodes are symbols in the source code (\eg tokens in region \circled{3} of ~Fig.\ref{fig:local_evaluation}), while non-terminal nodes encapsulate more than one terminal node to define the structure of a statement (\eg nodes containing children in region \circled{2} of ~Fig. \ref{fig:local_evaluation}). 

When designing our approach \astxplainer (see Sec.\ref{sec:approach}), we leveraged meaningful and interpretable information defined in Context-Free Grammars ($CFGs$). $CFGs$ are a set of rules containing the syntax and structural information of a language \cite{10.5555/1196416}. Ultimately CFGs define instructions that specify how different tokens (\ie Lexemes) are put together to form valid statements in every programming language.

_Definition 2:_\textbf{Context Free Grammars.} $CFG$ $\mathbb{G}$ is expressed as $\mathbb{G} = (\alpha, \lambda, \omega, \beta)$ where $\alpha$ denotes the finite set of non-terminal symbols, $\lambda$ the finite set of terminal symbols, $\omega$ the finite set of production rules and $\beta$ the start symbol. The set of production rules $\omega$ for any type of statement (\eg conditional, assignation, operator) is expressed in terms of the terminal and non-terminal symbols.

## The ASC-Eval Component

## Results

## Citation

## OLD
This theme supports rendering beautiful math in inline and display modes using [MathJax 3](https://www.mathjax.org/) engine.
You just need to surround your math expression with `$$`, like `$$ E = mc^2 $$`.
If you leave it inside a paragraph, it will produce an inline expression, just like $$ E = mc^2 $$.

To use display mode, again surround your expression with `$$` and place it as a separate paragraph.
Here is an example:

$$
\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)
$$

Note that MathJax 3 is [a major re-write of MathJax](https://docs.mathjax.org/en/latest/upgrading/whats-new-3.0.html) that brought a significant improvement to the loading and rendering speed, which is now [on par with KaTeX](http://www.intmath.com/cg5/katex-mathjax-comparison.php).


***

## Citations

Citations are then used in the article body with the `<d-cite>` tag.
The key attribute is a reference to the id provided in the bibliography.
The key attribute can take multiple ids, separated by commas.

The citation is presented inline like this: <d-cite key="gregor2015draw"></d-cite> (a number that displays more information on hover).
If you have an appendix, a bibliography is automatically created and populated in it.

Distill chose a numerical inline citation style to improve readability of citation dense articles and because many of the benefits of longer citations are obviated by displaying more information on hover.
However, we consider it good style to mention author last names if you discuss something at length and it fits into the flow well — the authors are human and it’s nice for them to have the community associate them with their work.

***

## Footnotes

Just wrap the text you would like to show up in a footnote in a `<d-footnote>` tag.
The number of the footnote will be automatically generated.<d-footnote>This will become a hoverable footnote.</d-footnote>

***

## Code Blocks

Syntax highlighting is provided within `<d-code>` tags.
An example of inline code snippets: `<d-code language="html">let x = 10;</d-code>`.
For larger blocks of code, add a `block` attribute:

<d-code block language="javascript">
  var x = 25;
  function(x) {
    return x * x;
  }
</d-code>

**Note:** `<d-code>` blocks do not look good in the dark mode.
You can always use the default code-highlight using the `highlight` liquid tag:

{% highlight javascript %}
var x = 25;
function(x) {
  return x * x;
}
{% endhighlight %}

***

## Layouts

The main text column is referred to as the body.
It is the assumed layout of any direct descendants of the `d-article` element.

<div class="fake-img l-body">
  <p>.l-body</p>
</div>

For images you want to display a little larger, try `.l-page`:

<div class="fake-img l-page">
  <p>.l-page</p>
</div>

All of these have an outset variant if you want to poke out from the body text a little bit.
For instance:

<div class="fake-img l-body-outset">
  <p>.l-body-outset</p>
</div>

<div class="fake-img l-page-outset">
  <p>.l-page-outset</p>
</div>

Occasionally you’ll want to use the full browser width.
For this, use `.l-screen`.
You can also inset the element a little from the edge of the browser by using the inset variant.

<div class="fake-img l-screen">
  <p>.l-screen</p>
</div>
<div class="fake-img l-screen-inset">
  <p>.l-screen-inset</p>
</div>

The final layout is for marginalia, asides, and footnotes.
It does not interrupt the normal flow of `.l-body` sized text except on mobile screen sizes.

<div class="fake-img l-gutter">
  <p>.l-gutter</p>
</div>

***

## Other Typography?

Emphasis, aka italics, with *asterisks* (`*asterisks*`) or _underscores_ (`_underscores_`).

Strong emphasis, aka bold, with **asterisks** or __underscores__.

Combined emphasis with **asterisks and _underscores_**.

Strikethrough uses two tildes. ~~Scratch this.~~

1. First ordered list item
2. Another item
⋅⋅* Unordered sub-list.
1. Actual numbers don't matter, just that it's a number
⋅⋅1. Ordered sub-list
4. And another item.

⋅⋅⋅You can have properly indented paragraphs within list items. Notice the blank line above, and the leading spaces (at least one, but we'll use three here to also align the raw Markdown).

⋅⋅⋅To have a line break without a paragraph, you will need to use two trailing spaces.⋅⋅
⋅⋅⋅Note that this line is separate, but within the same paragraph.⋅⋅
⋅⋅⋅(This is contrary to the typical GFM line break behaviour, where trailing spaces are not required.)

* Unordered list can use asterisks
- Or minuses
+ Or pluses

[I'm an inline-style link](https://www.google.com)

[I'm an inline-style link with title](https://www.google.com "Google's Homepage")

[I'm a reference-style link][Arbitrary case-insensitive reference text]

[I'm a relative reference to a repository file](../blob/master/LICENSE)

[You can use numbers for reference-style link definitions][1]

Or leave it empty and use the [link text itself].

URLs and URLs in angle brackets will automatically get turned into links.
http://www.example.com or <http://www.example.com> and sometimes
example.com (but not on Github, for example).

Some text to show that the reference links can follow later.

[arbitrary case-insensitive reference text]: https://www.mozilla.org
[1]: http://slashdot.org
[link text itself]: http://www.reddit.com

Here's our logo (hover to see the title text):

Inline-style:
![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 1")

Reference-style:
![alt text][logo]

[logo]: https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 2"

Inline `code` has `back-ticks around` it.

```javascript
var s = "JavaScript syntax highlighting";
alert(s);
```

```python
s = "Python syntax highlighting"
print s
```

```
No language indicated, so no syntax highlighting.
But let's throw in a <b>tag</b>.
```

Colons can be used to align columns.

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

There must be at least 3 dashes separating each header cell.
The outer pipes (|) are optional, and you don't need to make the
raw Markdown line up prettily. You can also use inline Markdown.

Markdown | Less | Pretty
--- | --- | ---
*Still* | `renders` | **nicely**
1 | 2 | 3

> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

Quote break.

> This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote.


Here's a line for us to start with.

This line is separated from the one above by two newlines, so it will be a *separate paragraph*.

This line is also a separate paragraph, but...
This line is only separated by a single newline, so it's a separate line in the *same paragraph*.
