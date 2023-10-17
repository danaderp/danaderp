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
The advent and proliferation of online open-source code repositories and rapid advancements in transformer-based neural large language models LLMs have served as a catalyst for the advancement of automated Software Engineering (SE) tools with rapidly advancing effectiveness. LLMs for code have demonstrated considerable proficiency across a diverse array of generative SE tasks, inclusive of, but not restricted to, code completion <d-cite key="Raychev2014CodeCW"></d-cite>\cite{Raychev2014CodeCW,MSR-Completion}, program repair \cite{Chen2019sequencer,ahmad_unified_2021}, and test case generation <d-cite key="Watson:ICSE2"></d-cite>. Moreover, these advancements are rapidly being introduced into commercial developer tools such as GitHub CoPilot <d-cite key="github_copilot"></d-cite> and Replit's Ghostwriter <d-cite key="ghostwriter"></d-cite>. 

However, the sheer complexity and size that enable the often surprising effectiveness of LLMs for code is a double-edged sword. That is, while these attributes enable LLMs to capture important patterns in code that allow them to be applied to a range of programming tasks, effectively _explaining_ and _evaluating_ the capabilities of these models is a challenging proposition --- they effectively function as ``black boxes'' that derive predictions from exceedingly complex internal model mechanics. Current research in both designing LLMs for code and in applying them to programming tasks typically makes use of existing benchmarks (e.g., CodeSearchNet~\cite{husain2019codesearchnet}, or HumanEval~\cite{chen_evaluating_2021}) and metrics that have been adapted from the field of natural language processing (NLP) such as accuracy, BLEU, METEOR, and ROUGE, as well as more recent metrics further tailored for code such as CodeBLEU~\cite{ren_codebleu_2020}. However, recent work has illustrated the limitations of benchmarks such as HumanEval~\cite{liu2023code}, and there has been growing criticism of automated metrics within the NLP community~\cite{molnar2019interpret,Kim2018InterpretabilityTCAV,wan_what_2022,liu_reliability_2023}. These deficiencies largely stem from the fact that such benchmarks and metrics are often targeted at evaluating functional or syntactic correctness of generated code or task performance, but are not able to _explain_ model predictions or capabilities in an interpretable manner.

Methods for _evaluating_ and _explaining_ LLMs for code are inextricably linked to one another. An informative evaluation requires some degree of explainability of model predictions, such that model behavior can be understood at a fine-grained level. However, the fundamental challenge in achieving explainability of LLMs for code lies in establishing a reliable mapping mechanism that can bridge the gap between a given model's predictions and human-understandable programming language (PL) concepts that can aid in explaining the model's decisions. As such, designing both effective evaluations and interpretability techniques for LLMs of code requires that one first establish this conceptual mapping.

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        <p align="center">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/blog_astxplainer/fig_1_generative_process_astxplainer.png' | relative_url }}" alt="centered image" title="example image"/>
        </p>
    </div>
</div>
<div class="caption">
    Figure 3. The evaluative and explainability method is composed of ASC-EVal, ASC-Causal, and ASC-Viz.
</div>

To overcome the challenges in explaining and evaluating LLMs for code we propose a novel method for enabling a reliable conceptual mapping of LLMs predictions to PL concepts, called \astxplainer, which collects and aggregates LLMs token predictions into a construct that we call Abstract Syntax Concepts (\asc), derived from Abstract Syntax Trees (ASTs). By explicitly mapping model predictions to code structure, \astxplainer provides a fine-grained methodology for examining _how_ models perform relative to programming language concepts, and can help model end-users reason about _why_ an LLMs may have made a certain set of predictions. \astxplainer's mapping of model predictions to \ascs enables two new types of evaluations for LLMs of code, and one novel interpretability technique that visualizes model \ascs to aid end users (i.e., developers using LLMs to auto-complete code) in understanding LLMs predictions. Fig.~\ref{fig:astxplainer} illustrates these three main components of \astxplainer.

The first evaluation technique, called \asceval is able to estimate the structural performance of a predicted syntax element in order to measure the uncertainty of the downstream code generative process (e.g., for code completion). The second evaluation technique called \asccausal, is capable of generating causal explanations that link these structural performance values with canonical model performance (i.e., Cross-Entropy Loss). Finally, \ascviz implements a practical interpretability technique by visualizing model LLMs prediction uncertainty, organized into AST structures, aiding end-users in understanding the reliability of model predictions in practice. We evaluate \asceval and \asccausal through a large-scale, comprehensive empirical study that evaluates 12 popular LLMs on a novel dataset of $$\approx$$ 10 million tokens that are exclusive of the model's training data. Furthermore, to evaluate the effectiveness of \ascviz, we conduct a user study examining the utility of multiple visualizations in aiding developers to understand and explaining model predictions. The results of our empirical study lead to novel insights regarding the performance of LLMs for code, and user study illustrates the promising utility of \ascviz. 

## Background & Related Work

ASTxplainer is an evaluative and explainability approach to quantify the prediction uncertainty of LLMs for code. LLMs are the result of scaling up billions of parameters for context-aware word representations from pre-trained models\cite{zhao_survey_2023}. This section defines and formalizes the basic elements of our approach. We provide a definition of LLMs and how to evaluate them, the definition of Abstract Syntax Trees (ASTs) and how they were employed for probing, and finally, the explainability methods for LLMs. 

Our research focused on LLMs because of their outstanding performance on code-based generative tasks. While other representations exist, such as graph-based models~\cite{allamanis2018learning,Allamanis19}, we focus our discussion on sequence-based representations for simplicity. The goal of sequence-based models is to statistically learn a representation of a software artifact (e.g., snippet, comments, or test cases). We refer to SE-specific sequence-based data as a software corpus $$\mathcal{S}$$. Given the sequential nature of $\mathcal{S}$, we can decompose $$\mathcal{S}$$ into a desired granularity of tokens, words, or sub-words \cite{Karampatsis2019} by using a transformation function $$\Gamma(\mathcal{S})= w_1,...,w_I$$ (i.e., _tokenizers_). This transformation function is a tokenization method for converting a software corpus into a sequence of discrete objects $w_i$  for $$1 \leqslant i \leqslant I$$. Note that $$w_i \in V$$, where the vocabulary $$V$$ is a finite set.

Given this definition, a statistical language model is a probability distribution $$P$$ over a fixed granularity of sequences of software corpora $$\mathcal{S}$$. We can factorize the joint distribution over the $$i-$$dimension as: $$P(\mathcal{S}) = P(w_1,...,w_I) = \prod_{i = 1}^{I} P(w_i | w_{<i})$$. Due to the discrete nature of the data, the expression $$P(w_i | w_{<i})$$ can be estimated using a classifier. The classifier, in our particular case, is a LLM \cite{Bengio2003AModel}. Hence, rather than using _n_-grams or Markov Models to approximate $$P(w_i | w_{<i})$$ \cite{Karampatsis2020Open-VocabularyAbstract}, it is convenient to use a latent model $$P(w_i | w_{<i} ) \approx P(w_i | h_i )$$, where $h_i$ is known as a _hidden state_ that embeds the sequence information from past observations up to the time step $$i$$.

Depending on _how_ the sequence is processed, the hidden state $h_i$ can be computed using either _Encoder-Only_, _Encoder-Decoder_, or _Decoder-Only_ architectures according to the _transformers'_ layers ~\cite{vaswani2017transformers}. One popular bidirectional objective function used widely in representation learning is _masked language_ modeling \cite{devlin_bert_2019}. This function aims to predict masked text pieces based on the surrounding context. CodeBERT \cite{feng_codebert_2020}, CuBERT (345M) \cite{kanade_learning_2020} CodeRoBERTa  \cite{lin_span_2022}, and GraphCodeBERT \cite{guo_graphcodebert_2021} are examples of _Encoder-Only_ models for code. In programming contexts, these methods provide useful representations of code sequences for downstream tasks such as code classification, clone and defect detection. CodeT5 \cite{wang_codet5_2021} and PLBART \cite{ahmad_unified_2021} are examples of _Encoder-Decoder_ models. These models encode an input sequence and, then, this encoded sequence is decoded with a different architecture. Encoder-Decoder models are trained with the goal of reconstructing masked input sequences \cite{lewis_bart_2019}. Additionally, they have been employed for SE tasks such as code summarization, and code generation using masks\cite{wang_codet5_2021}. Finally, _Decoder-Only_ models predict the probability of a token given a preceding sequence. CodeGPT \cite{lu_codexglue_2021}, CodeParrot \cite{codeparrot}, GPT-Neo \cite{black_sid_2021_5297715}, GPT-J \cite{gpt-j}, Codex \cite{openai_codex}, GPT-NeoX \cite{GPTNeoX}, and Google's left-to-right decoder-only Transformer language models \cite{vaswani2017transformers,austin2021program} are examples of _Decoder-Only_ models for code. 

Although our proposed approach \astxplainer was designed to be compatible with either type of LLMs, this paper concentrated on _Decoder-Only_ models due to their popularity for code-based generative tasks \cite{xu_systematic_2022}. These models share a common property: _the ability to connect previously processed information to a present task, such as using an initial sequence of tokens to predict new code tokens_. The resulting auto-completed sequence should be coherent with respect to the context of the initial sequence. This property is known as the ability to model _long-range dependencies_ \cite{karpathy2015understand}. 

_Definition 1:_ __Decoder-Only Transformers.__ Decoder-Only models update the hidden state $$h_i = f(h_{i-1}, w_{<i})$$ using past inputs $$w_{<i}$$ and a previous hidden state $$h_{i-1}$$. In other words, these models function in a feed-forward manner that predicts future values from historical values directly. LLMs trained on source code have the ability to generate tokens or sub-words given a history. Hence, decoder-only models are employed as generative models $$\hat{w_i} \backsim P(w_i | w_{<i} ) = \sigma(y)_i = \frac{e^{y_{w_i}}}{\Sigma_j e^{y_j}}$$. 

In the previous approximation, the predicted token $$w_i$$ is _conditioned_ by the previous information. The term $y_j$ represents the _non-normalized log-probabilities_ for each output token $$j$$. We extracted and normalized these __log-probabilities__ from the last layer of LLMs to estimate the __Next-token Predictions__ (\ntp) in \astxplainer (see Sec.\ref{sec:approach}). This estimation relies on the softmax function. The softmax $$\sigma_i$$ returns a distribution over predicted output classes, in this case, the classes are each token in the previously introduced vocabulary $V$. It is expected that the predictions contained in $$\sigma_i$$ are influenced by previous inputs of the sequence $$w_{<i}$$. 

_Probing_ is a supervised analysis to determine which type of parameters (e.g., input code snippets, tokenization process, number of hidden layers, and model size) influence the learning process in machine learning models \cite{troshin_probing_2022}. The purpose of probing is to assess whether hidden representations of machine learning models (i.e., LLMs) encode specific linguistic properties such as syntactic structures of programming languages. For example, Lopez et al., \cite{lopez_ast-probe_2022} trained a linear classifier to show that code syntactic structures are encoded in pre-trained models in the form of Abstract Syntax Trees (ASTs). Lopez et al.'s approach demonstrates that the middle layers of pre-trained models contain ASTs' information\cite{lopez_ast-probe_2022}.

Nonetheless, instead of proposing another syntax probe, our approach ASTxplainer adapts AST information to evaluate and explain LLMs (see Sec.~\ref{sec:approach}). ASTs are defined as a formal representation of syntactical structures built upon linguistic elements of PLs. ASTs are formed according to the production rules defined in Context Free Grammar (CFGs). More precisely, production rules are functions that combine terminal and non-terminal nodes into statements. Terminal nodes are symbols in the source code (e.g., tokens in region (3) of ~Fig.\ref{fig:local_evaluation}), while non-terminal nodes encapsulate more than one terminal node to define the structure of a statement (e.g., nodes containing children in region (2) of ~Fig. \ref{fig:local_evaluation}). 

When designing our approach ASTxplainer (see Sec.\ref{sec:approach}), we leveraged meaningful and interpretable information defined in Context-Free Grammars ($$CFGs$$). $$CFGs$$ are a set of rules containing the syntax and structural information of a language \cite{10.5555/1196416}. Ultimately CFGs define instructions that specify how different tokens (i.e., Lexemes) are put together to form valid statements in every programming language.

_Definition 2:___Context Free Grammars.__ $$CFG$$ $$\mathbb{G}$$ is expressed as $$\mathbb{G} = (\alpha, \lambda, \omega, \beta)$$ where $$\alpha$$ denotes the finite set of non-terminal symbols, $$\lambda$$ the finite set of terminal symbols, $$\omega$$ the finite set of production rules and $$\beta$$ the start symbol. The set of production rules $$\omega$$ for any type of statement (e.g., conditional, assignation, operator) is expressed in terms of the terminal and non-terminal symbols.



## The ASC-Eval Component

LLMs for code can be considered a black box because of their uncertain behavior when predicting tokens. To estimate such uncertainty, we can employ _explainability_ methods on LLMs. Explainability aims to understand how a model operates and comes to decisions either by exploring inner layers or performing perturbation analysis on the models' inputs \cite{belle_principles_2020,molnar_interpretable_2020}. For example, Gholizadeh \etal \cite{gholizadeh_model_2021} propose a local explainability technique, namely layer-wise relevant propagation (LRP), that computes the importance of an interpretable _n_-gram in classifying a text sequence. LRP calculates a score with the sum of activated weights during the back-propagation to identify the most influential _n_-grams. This score is employed for explaining the importance of a given _n_-gram for a canonical (i.e., SVM) and a neural model(i.e., CNN). The authors demonstrated that LRP outperforms the gradient-only-based and permutation-only-based explainability techniques \cite{gholizadeh_model_2021}. It is important to clarify that, in our research, _explainability_ and _interpretability_ are used interchangeably. 

In the context of pre-trained models for code, Liu \etal experimented with Encoder-Decoder models for code2code and comment2code tasks (e.g., T5, CodeText, and CodeTrans). Their research aims at explaining why neural models generate code sequences reliably by identifying tokens that contribute the most to a sequence prediction \cite{liu_reliability_2023}. Moreover, Vasconcelos \etal propose a technique that highlights generated code using an uncertainty threshold. Their approach points out fragments of the sequence where developers can intervene upon the uncertainty threshold \cite{vasconcelos_generation_2023}. On the other hand, we can explain pre-trained models for code using structural information. For instance, Wan \etal conducted an interpretability analysis on Encoder-only models (e.g., CodeBert and GraphCodeBert) focusing on three aspects: 1) how the self-attention weights align with the syntax structure, 2) whether the syntax structure is encoded in the hidden layers, and 3) how pre-trained models induce syntax structure \cite{wan_what_2022}. 

Even though previous research has introduced explainability techniques to analyze pre-trained models with structural information, those techniques  have been tested and designed for modest-size Encoder-Only models (i.e., less than 1B). Conversely, our study \astxplainer proposes not only an explainability technique that contextualizes canonical metrics (i.e., cross-entropy loss) based on causal inference (see Fig.\ref{fig:asc_causal}) but also an evaluative metric (\asceval) for Decoder-only LLMs that predicts ASTs terminal and non-terminal nodes. More importantly, we introduce and control a set of confounders based on code features (e.g., AST-levels, AST-nodes, and number of tokens) to properly estimate the relationship between \asceval and canonical metrics (see Tab.~\ref{tab:correlations}).

Kim \etal \cite{Kim2018InterpretabilityTCAV} introduce a formal mathematical structure known as a __function for explainability__ ($$\varphi$$). We use this definition to formally describe what constitutes an explainable method in SE. Most LLMs for code operate by predicting tokens $$P(w_i|d_i)$$ that do not _inherently_ match high-level concepts a human can easily understand. Kim \etal claim that such difficulty can be expressed mathematically as representing the state of LLMs as a vector space ($$\Vec{m}$$). Conversely, humans or, in our study, developers operate in a different vector space $$\vec{h}$$, which corresponds to an unknown set of __human-interpretable concepts__ ($$h$$). As such, our main challenge is to map $$\Vec{m} \to \Vec{h}$$ bridging this gap between the disparate vector spaces. The _key insight_ of \astxplainer is the formalization of an explainability function $$\varphi$$ for LLMs of code.

_Definition 3:_ __Interpretability Function for Next Token Predictions.__ Consider $$\varphi: \Vec{m} \to \Vec{h}$$. In this formulation, $$\Vec{m}$$ represents an approximation of a model's vector space as measured through token prediction performance at different granularity levels (i.e., normalized log-probabilities). This vector space approximation is then mapped to human-understandable concepts $$\Vec{h}$$ that represent programming language syntactic concepts (i.e., terminal and non-terminal nodes).

While LLMs have seen striking advances with regard to code generation and other downstream SE tasks \cite{Chen2021EvaluatingCode, watson2020dl4se}, researchers are still not able to evaluate what aspects of code are actually statistically learned by these models. In this section, we propose a new metric, \asceval, to showcase the statistical behavior of syntactic elements generated by LLMs. Our proposed \asceval comprises the basic units for explainability (see Fig.~\ref{fig:ast_eval}) as Abstract Syntax Concepts (\asc), an alignment function $$\delta$$ that links tokens with ASTs, and an aggregation function $$\theta$$ that estimates the prediction performance of a terminal and non-terminal nodes. We propose an explainability function $$\varphi$$ that relies on the alignment function $\delta$ and the aggregation function $$\theta$$ to perform the mapping from log-probabilites (i.e., \ntp) to developer-understandable concepts (i.e., \asc). 

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        <p align="center">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/blog_astxplainer/fig_1_ast_eval.png' | relative_url }}" alt="centered image" title="example image"/>
        </p>
    </div>
</div>
<div class="caption">
    Figure 3. \asceval Components. Left: Nodes are employed as ``concepts''. Center: Each token is aligned to the end nodes of the AST with an offset function. Right: Node probabilities are estimated with an aggregation function.
</div>

### Abstract Syntax Concepts (\asc)
\asceval can be formally defined (see Def.~\ref{def:explainability_function}) as an explainability function $$\varphi$$ of token predictions of LLMs using Context Free Grammars. We introduce the term __Abstract Syntax Concepts__ (\asc) to represent the terminal and non-terminal symbols in a Context Free Grammar (see Def~.\ref{def:cfg}). Specifically, to approximate a LLMs' vector space, in $$\Vec{m}$$, we extract the last layer to calculate \ntp, which is, in fact, a generative measure of performance. Then in $\Vec{h}$, we map the model's prediction performance at the token level (\ntp) to \asc (for which we define a set of categories $\mathcal{H}$), to make it easier to interpret what aspects of LLMs are _effective_ or _erroneous_ at predicting. 

In PLs, terminal and non-terminal nodes retain different semantic meanings. For instance, \texttt{\small `identifier'} and \texttt{\small `string'} nodes correspond to a common _Natural Language_ concept category. As such, we can group nodes $n$ into semantically meaningful _categories_ $$\mathcal{H}$$. Fig.~\ref{fig:largeTreeMap} depicts some of our proposed categories for Python. These categories will allow \asceval to assign semantic meaning to predicted \asc. \asc are the fundamental mathematical units for enabling the evaluation and explainability of LLMs. Figure \ref{fig:largeTreeMap} depicts some of the concepts used to evaluate LLMs with \asceval. Concepts $$n \in N$$ are types of symbols defined by tree-sitter's $CFG$ \cite{tree-sitter}. In summary, Each token in a sequence $$s$$ can be assigned to a category $$h \in \mathcal{H}$$. With our categories $$\mathcal{H}$$, researchers and developers can easily associate LLMs' performance to particular structural code attributes. As such, \asceval allows for LLMs Next-token Predictions to be explained in a developer-centric way.


Fig~\ref{fig:ast_eval}-A depicts the AST representation of a Python snippet of a naive implementation of the function $$countCharts$$. This function counts and returns the number of occurrences of a given character for an input string. In the AST representation, the leaf nodes correspond to the terminal tokens used in the snippet, while the intermediate nodes correspond to non-terminals. Our approach relies on the tree-sitter library \cite{tree-sitter} to construct the AST representations of the snippets. Once the AST has been parsed, we can access the information for all nodes and retrieve useful properties such as their type, children, and location.


### AST Alignment function ($\delta$)

Figure~\ref{fig:ast_eval}-B illustrates the process of aligning terminal and non-terminal nodes in the AST representation with their corresponding tokens. Prior to this alignment process, we split the $countCharts$ snippet $s$ into tokens using the model tokenizer $$\Gamma(s) = (w_1,...,w_i)$$. Since the tokenizer may produce a sequence of tokens where each token does not necessarily matches with a single terminal node, a single node in the AST may contain more than one associated token. In fact, intermediate nodes are aligned with a sub-sequence of the original snippet rather than a single token. We define for this purpose the alignment function $$\delta: N \to s_{<=i}$ where $s_{<=i}$$ corresponds to a subsequence of a snippet and $N$ is the set of terminal and non-terminal nodes. We leverage the offset property of each AST node to conduct this process, in other words, we search for all the tokens in $s$ that are located within the offset range of each node. To illustrate how function $\delta$ works, let's consider the example in Figure~\ref{fig:ast_eval}-B, in the sub-tree the terminal node \texttt{\small `('} is aligned with token \framebox(0.5cm,0.34cm){(} while the sibling node \texttt{\small `identifier'} is aligned with tokens \framebox(0.7cm,0.34cm){str} \framebox(0.7cm,0.34cm){ing}. The parent node \texttt{\small `parameters'} will be consequently aligned with \framebox(0.5cm,0.34cm){(} \framebox(0.7cm,0.34cm){str} \framebox(0.7cm,0.34cm){ing} \framebox(0.5cm,0.34cm){,} \framebox(0.8cm,0.34cm){char} \framebox(0.9cm,0.34cm){acter} \framebox(0.5cm,0.34cm){)}.

### AST Aggregation function ($$\theta$$)

We design an aggregation function $$\theta$$ that computes our proposed metric \asceval, which represents how confident a terminal or non-terminal node $n$ is predicted by an \llm. By relating these node predictions to an actual node symbol, we gain an understanding of how well a studied model is _generating code_. These \asceval performance values can also uncover specific long-range interactions and map them into an AST visual structure (see Sec.~\ref{sec:approach-3}). \asceval performs at two levels of granularity depending on the scope of the analyzed corpus $$\mathcal{S}$$. We refer to such granularity as _local_ and _global} aggregation. Local aggregations operate for a code snippet, while global aggregations operate for a corpus. Although local aggregation can provide a \asceval value for a single snippet, this aggregation allows computing an average of aggregated values at snippet granularity.  

Figure~\ref{fig:ast_eval}-C shows the aggregation function used to compute the prediction probability for each node. Once the tokens are aligned with their corresponding nodes using $$\delta$$, we traverse the entire AST and aggregate the \ntp probabilities of their associated tokens. The aggregation function $$\theta$$ can take the form of a statistical average, median or max values depending on the user configuration. In our study, we set the aggregation $$\theta: N \to  median(\delta(N))$$ for a subset of tokens $$s_{<=i}$$. For example, as illustrated in Fig.~\ref{fig:ast_eval}-C, the parent node \texttt{\small `parameters'} has an associated average value of $0.23$. This parent node average was aggregated with its terminal values: \texttt{\small `('} with $0.07$, \texttt{\small `identifier'} with $0.4$, \texttt{\small `,'} with $$0.5$$, \texttt{\small `identifier'} with $0.1$, and \texttt{\small `)'} with $0.1$.

<div class="row">
    <div class="col-sm mt-3 mt-md-0">
        <p align="center">
        <img class="img-fluid rounded z-depth-1" src="{{ '/assets/img/blog_astxplainer/Concepts_tree_map.jpg' | relative_url }}" alt="centered image" title="example image"/>
        </p>
    </div>
</div>
<div class="caption">
    Figure 3. \asceval for 10 \asc Categories and 2 LLMs (\monoIIII and \gptI).
</div>


## Citation

```latex
@misc{palacio_evaluating_2023,
	title = {Evaluating and Explaining Large Language Models for Code Using Syntactic Structures},
	url = {http://arxiv.org/abs/2308.03873},
	publisher = {{arXiv}},
	author = {Palacio, David N. and Velasco, Alejandro and Rodriguez-Cardenas, Daniel and Moran, Kevin and Poshyvanyk, Denys},
	urldate = {2023-08-22},
	date = {2023-08-07},
	langid = {english},
	eprinttype = {arxiv},
	eprint = {2308.03873 [cs]},
}
```

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
