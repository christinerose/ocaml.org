---
title: 'Eio From a User''s Perspective: An Interview With Simon Grondin'
description: Discover how the Eio library was enhanced with Simon Grondin's contributions,
  addressing concurrency challenges and improving performance for OCaml projects.
url: https://tarides.com/blog/2024-09-19-eio-from-a-user-s-perspective-an-interview-with-simon-grondin
date: 2024-09-19T00:00:00-00:00
preview_image: https://tarides.com/blog/images/juggling-eio-1360w.webp
authors:
- Tarides
source:
---

<p>Are you curious about Eio but not sure what to expect? Eio is an effects-based direct-style concurrency library for OCaml 5. I recently spoke with <a href="https://github.com/SGrondin">Simon Grondin</a> from <a href="https://asemio.com">Asemio</a> about his personal experience using the I/O library <a href="https://github.com/ocaml-multicore/eio">Eio</a>. He was kind enough to share the good and the bad and give me insight into how the library has worked for his projects.</p>
<p>If you want to know what programming with Eio is like from another user's perspective, this interview is for you. Let's explore what Simon had to say!</p>
<h2>The Interview</h2>
<h3>&quot;Hello Simon, thank you for meeting with me today! What first got you curious about Eio?&quot;</h3>
<p>&ldquo;We use OCaml at Asemio, and I use OCaml a lot for my own projects. But when it came to concurrent code, I had accepted that to reap the benefits, I needed to deal with the increased complexity that came with them. In traditional concurrency, the developer relies on abstractions for tasks and promises using async/await. I had grown to assume that <a href="https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/">coloured functions</a> was a necessary price to pay when the Eio library with its effect handlers announced that we didn't have to deal with this problem at all.&quot;</p>
<blockquote>
<p>&quot;Concurrency squeezes more out of code, so people use it, accepting that they will pay the cost of increased complexity. But we can enjoy the benefits of concurrency without the cost!&quot;</p>
</blockquote>
<p>&quot;I had heard of Eio relatively early in its development, around version 0.3. At that point, it was still in flux, and I wasn't comfortable that I could build something lasting on top. Then I saw the announcement post for version 0.10 on June 11th 2023, and that's when I decided to try and switch. The project looked much more stable, the developers had resolved several initial issues, and the code wasn't being rewritten nearly as much as before. All of my previous hesitations had been addressed.&rdquo;</p>
<h3>&quot;What did you do next?&quot;</h3>
<p>&ldquo;I had a project in mind for testing Eio, a tool I had initially developed as an internal application. At Asemio, we regularly process huge Excel files (think millions of cells). The challenge with these files is that there are multiple ways that they can be organised internally, and it is impossible to know how they are organised without opening them. We need to be able to stream and read the data of very large files.</p>
<p>This is where the <a href="https://github.com/asemio/SZXX">SZXX</a> library comes in. It's a streaming ZIP, XML, and XLSX library that can stream data from these file formats even when reading from a network socket, either in constant memory or with user-defined memory usage guarantees. I had initially used the <a href="https://github.com/ocsigen/lwt"><code>Lwt</code></a> library to implement concurrency in SZXX, but I decided to convert it to Eio.&rdquo;</p>
<h3>&quot;What benefit did you expect to see from switching to Eio?&quot;</h3>
<p>&ldquo;From my perspective, the main problem with using <code>Lwt</code> was the <a href="https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/">function colouring problem</a>. Micromanaging code in that way is time-consuming, and I wanted to learn Eio mainly because I knew that effects could potentially eliminate the extra work and complexity that came with <code>Lwt</code>.</p>
<p>I also learned that Eio came with integrated access to <code>io_uring</code>, letting the developer use it without additional effort and the function colouring problem. These were the two features I was the most interested in when converting the SZXX project from Lwt to Eio.</p>
<p>In addition, I had observed a split between Lwt and Async within the community,  and for a while, I had been looking for a solution that could bridge the gap. From my research into the I/O library at that time, I felt confident that it had the potential to 'heal the split' between the different library users. In a way, converting SZXX to Eio was my way of testing that theory to see what effect the transition would have.&quot;</p>
<h3>&quot;What was your initial experience with Eio? Did you have any frustrations?&quot;</h3>
<p>&quot;I actually did! When I first started using Eio, I had a hard time understanding how Paths, Flows, Files (and others) relate to one another. I also experienced a lack of documentation and examples of abstraction to help the newcomer get up and running. These are some of the first things a new user will experiment with, and they must work well. Since then, I have helped improve the documentation (alongside several other contributors) and made other quality-of-life contributions to the library.&quot;</p>
<p>These initial friction points were not enough to dissuade me from continuing my project, and after that initial hurdle, I was very happy.&quot;</p>
<blockquote>
<p>&quot;I had been prepared to accept a performance degradation to get the benefits I was looking for, but I was pleasantly surprised to note that performance actually improved.&rdquo;</p>
</blockquote>
<h3>&quot;That's great! Did Eio affect your project in any other ways? Did anything surprise you?&quot;</h3>
<p>&ldquo;I was unprepared for just how much of a difference using non-monadic code would make. Eio has this concept called a Switch, which ties resources to scopes. It cleans up your code by managing the lifecycle of open resources automatically, for example, turning off background processes, closing file handles, and ensuring that all auxiliary states are set to their desired state upon exiting the scope.</p>
<p>When you write parallel programs, there can be hundreds of thousands of interleavings and computations, and ensuring that each computation is handled correctly has always been a challenge with monadic-style code. But with Eio and effects-based concurrency, the switch handles much of that complexity for you.</p>
<p>In fact, both of these benefits work synergistically. They include solving the function colouring problem (meaning you don't need to distinguish between async and 'normal' functions) and using non-monadic code. Each amplifies the other almost exponentially and frees up a lot of your complexity budget.&quot;</p>
<blockquote>
<p>&quot;The human brain limits the complexity of code, and at some point, you just can't keep making things smaller to make them simple enough. Eio helps reduce complexity. With Eio, I was able to simplify and remove so much bloat from the code and achieve some really tricky optimisations, pushing the limit of what was possible.&rdquo;</p>
</blockquote>
<h3>&quot;That's an interesting insight, and I think one that only someone with real user experience can make. It's great to hear what results the user might expect. I know you have made significant contributions to Eio as well, and that the team has made you a maintainer in response to your contributions and reviews. Can you tell me about some of those?&quot;</h3>
<p>&ldquo;I started contributing to Eio from around version 0.11 and onwards. Some of my main projects include: <a href="https://github.com/ocaml-multicore/eio/blob/main/README.md#executor-pool"><code>executor_pool</code></a>, developing an <a href="https://github.com/Chris00/ocaml-csv/pull/40">Eio adapter for the popular CSV library</a> that I also <a href="https://github.com/inhabitedtype/angstrom/pull/227">added to Angstrom</a>, as well as work on an internal thread pool to speed up platforms without io_uring support. Along the way, I have added resources to Eio that make it easier for people to adopt the tool. For example, I designed the executor_pool module based on common patterns that I had often used in my projects.</p>
<p>Regarding the adaptors, in OCaml, library authors need to explicitly write one adaptor per I/O library they choose to support. The popular CSV library already had adaptors for both <code>Async</code> and <code>Lwt</code>. I knew that it would be hard for certain users to pick up Eio if it did not have an adaptor, so I wrote one and added it to both CSV and Angstrom. A lot of OCaml software depends on Angstrom through one dependency or another, and without Eio support, those codebases cannot make the switch to Eio.&rdquo;</p>
<h3>&quot;Thank you for answering my questions and sharing your experience with Eio! Do you have any final thoughts you would like to share?&quot;</h3>
<blockquote>
<p>&ldquo;Eio helped me reason about my code, and I discovered bugs and problems because of how much Eio had cleaned up the code. I uncovered hidden bugs in every program I converted from Lwt to Eio. Every single one also ended up being faster, not because Eio itself was faster (it was as fast as Lwt), but because of the optimisations I could now afford to make, thanks to the reduced complexity.&rdquo;</p>
</blockquote>
<h2>Stay in Touch</h2>
<p>If you have questions about Eio or how to use it, you can fill in our <a href="https://tarides.com/contact/">contact form</a>, and we will contact you. You can also ask questions on the <a href="https://discuss.ocaml.org/">OCaml Discuss forum</a> or open issues and pull requests in the <a href="https://github.com/ocaml-multicore/eio">Eio repo</a>.</p>
<p>To keep up with our activities, you can always follow us on <a href="https://twitter.com/tarides_">X</a> (formerly known as Twitter), <a href="https://www.linkedin.com/company/tarides">LinkedIn</a>, <a href="https://mastodon.social/@tarides">Mastodon</a>, <a href="https://www.threads.net/@taridesltd">Threads</a>. We look forward to connecting with you!</p>

