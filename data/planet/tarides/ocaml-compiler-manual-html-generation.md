---
title: OCaml Compiler Manual HTML Generation
description: Enhanced OCaml Manual URLs for better readability and version-specific
  references, providing a seamless user experience and improving backlink quality.
url: https://tarides.com/blog/2024-07-17-ocaml-compiler-manual-html-generation
date: 2024-07-17T00:00:00-00:00
preview_image: https://tarides.com/blog/images/compiler-manual-1360w.webp
authors:
- Tarides
source:
---

<p>In order to avoid long, confusing URLs on the OCaml Manual pages, we set out to create a solution that shortens these URLs, including section references, and contains the specific version. The result improves readability and user experience. This article outlines the motivation behind these changes and how we implemented them.</p>
<h2>Challenge</h2>
<p>The OCaml HTML manuals have URL references such as https://v2.ocaml.org/manual/types.html#sss:typexpr-sharp-types, and they do not refer to any specific compiler version. We needed a way to easily share a link with the version number included. The OCaml.org page already has a mention of the compiler version, but it refers to specific https://ocaml.org/releases.</p>
<p>We wanted a canonical naming convention that is consistent with current and future manual releases. It would also be beneficial to have only one place to store all the manuals, and the users of OCaml.org should never see redirecting URLs in the browser. This will greatly help increase the overall backlink quality when people share the links in conversations, tutorials, blogs, and on the Web. A preferred naming scheme should be something like:</p>
<p>https://v2.ocaml.org/releases/latest/manual/attributes.html
https://v2.ocaml.org/releases/4.12/manual/attributes.html</p>
<p>Using this, we redirected the v2.ocaml.org to OCaml.org for the production deployment. Also, the changes help in shorter URLs that can be easily remembered and shared. The rel=&quot;canonical&quot; is a perfectly good way to make sure only https://ocaml.org/manual/latest gets indexed.</p>
<h2>Implementation</h2>
<p>After a detailed discussion, the following UI mockup to switch manuals was provided <a href="https://github.com/ocaml/ocaml.org/issues/534#issuecomment-1318570350">via GitHub issue</a>, and <em>Option A</em> was selected.</p>
<p><img src="https://tarides.com/blog/images/UI-Mockup-1360w~juSPFyoGQry1P2d6IQH6iA.webp" sizes="(min-width: 1360px) 1360px, (min-width: 680px) 680px, 100vw" srcset="/blog/images/UI-Mockup-170w~SAoPK_zlNbBuzRgvQCTM_Q.webp 170w, /blog/images/UI-Mockup-340w~DlpF3X72C2MTNVPZE1GxSQ.webp 340w, /blog/images/UI-Mockup-680w~yXlq1opL_GnA_cth01Ddlw.webp 680w, /blog/images/UI-Mockup-1360w~juSPFyoGQry1P2d6IQH6iA.webp 1360w" alt="UI Mockup"/></p>
<p>Our proposed changes to the URL are shown below:</p>
<p>Current: https://v2.ocaml.org/releases/5.1/htmlman/index.html<br/>
Suggested: <code>https://ocaml.org/manual/5.3.0/index.html</code></p>
<p>Current: https://v2.ocaml.org/releases/5.1/api/Atomic.html<br/>
Suggested: <code>https://ocaml.org/manual/5.3.0/api/Atomic.html</code></p>
<h2>HTML Compiler Manuals</h2>
<p>The HTML manual files are hosted in a separate GitHub repository at https://github.com/ocaml-web/html-compiler-manuals/. It contains a folder for each compiler version, and it also has the manual HTML files.</p>
<p>A script to automate the process of generating the HTML manuals is also available at https://github.com/ocaml-web/html-compiler-manuals/blob/main/scripts/build-compiler-html-manuals.sh. The script defines two variables, DIR and OCAML_VERSION, where you can specify the location to build the manual and the compiler version to use. It then clones the <code>ocaml/ocaml</code> repository, switches to the specific compiler branch, builds the compiler, and then generates the manuals. The actual commands are listed below for reference:</p>
<pre><code>echo &quot;Clone ocaml repository ...&quot;
git clone git@github.com:ocaml/ocaml.git

# Switch to ocaml branch
echo &quot;Checkout $OCAML_VERSION branch in ocaml ...&quot;
cd ocaml
git checkout $OCAML_VERSION

# Remove any stale files
echo &quot;Running make clean&quot;
make clean
git clean -f -x

# Configure and build
echo &quot;Running configure and make ...&quot;
./configure
make

# Build web
echo &quot;Generating manuals ...&quot;
cd manual
make web
</code></pre>
<p>As per the new API requirements, the <code>manual/src/html_processing/Makefile</code> variables are updated as follows:</p>
<pre><code>WEBDIRMAN = $(WEDBIR)/$(VERSION)
WEBDIRAPI = $(WEBDIRMAN)/API
</code></pre>
<p>Accordingly, we have also updated the <code>manual/src/html_processing/src/common.ml.in</code> file OCaml variables to reflect the required changes:</p>
<pre><code>
let web_dir = Filename.parent_dir_name // &quot;webman&quot; // ocaml_version

let docs_maindir = web_dir

let api_page_url = &quot;api&quot;

let manual_page_url = &quot;..&quot;
</code></pre>
<p>We also include the https://plausible.ci.dev/js/script.js script to collect view metrics for the HTML pages. The manuals from 3.12 through 5.2 are now available in the https://github.com/ocaml-web/html-compiler-manuals/tree/main GitHub repository.</p>
<h2>OCaml.org</h2>
<p>The OCaml.org Dockerfile has a step included to clone the HTML manuals and perform an automated production deployment as shown below:</p>
<pre><code>RUN git clone https://github.com/ocaml-web/html-compiler-manuals /manual

ENV OCAMLORG_MANUAL_PATH /manual
</code></pre>
<p>The path to the new GitHub repository has been updated in the configuration file, along with the explicit URL paths to the respective manuals. The v2 URLs from the <code>data/releases/*.md</code> file have been replaced without the v2 URLs, and the <code>manual /releases/</code> redirects have been removed from <code>redirection.ml.</code> The <code>/releases/</code> redirects are now handled in <code>middleware.ml</code>. The caddy configuration to allow the redirection of v2.ocaml.org can be implemented as follows:</p>
<pre><code>v2.ocaml.org {
	redir https://ocaml.org{uri} permanent
}
</code></pre>
<h2>Call to Action</h2>
<p>You are encouraged to checkout the latest <a href="https://github.com/ocaml/ocaml">OCaml compiler from trunk</a> and use the <code>build-compiler-html-manual.sh</code> script to generate the HTML documentation.</p>
<p>Please do report any errors or issues that you face at the following GitHub repository: https://github.com/ocaml-web/html-compiler-manuals/issues</p>
<p>If you are interested in working on OCaml.org, please message us on the <a href="http://discord.ocaml.org">OCaml Discord</a> server or reach out to the <a href="https://github.com/ocaml-web//html-compiler-manuals">contributors in GitHub</a>.</p>
<h2>References</h2>
<ol>
<li>
<p>(cross-ref) Online OCaml Manual: there should be an easy way to get a fixed-version URL. https://github.com/ocaml/ocaml.org/issues/534</p>
</li>
<li>
<p>Use <code>webman/*.html</code> and <code>webman/api</code> for OCaml.org manuals. https://github.com/ocaml/ocaml/pull/12976</p>
</li>
<li>
<p>Serve OCaml Compiler Manuals. https://github.com/ocaml/ocaml.org/pull/2150</p>
</li>
<li>
<p>Simplify and extend <code>/releases/</code> redirects from legacy v2.ocaml.org URLs. https://github.com/ocaml/ocaml.org/pull/2448</p>
</li>
</ol>

