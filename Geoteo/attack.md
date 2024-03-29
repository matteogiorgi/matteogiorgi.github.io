<p style="text-align:center; border:1px solid #d0d0cc;">
  <img width=60% style="padding:30px;" src="pics/wiener.png">
</p>

Few years ago I wrote a brief paper regarding the [RSA cryptosystem](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) and the attack M.J. Wiener published in 1990. I tried to create a self-contained work, emphasising the power of playing with [continued fractions](https://en.wikipedia.org/wiki/Continued_fraction) using *Legendre theorem*. The attack states that when there is a small private exponent, the RSA module $N$ could be factorized in $\mathcal{O}\big(log_2(N)\big)$, let's take a peak on how it works using an example.

There are three numbers you need to know when we talk about the RSA cryptosystem: the module $N$ plus the exponents $e$ and $d$. So, given the public key $(e,N)$ of an RSA with a small private exponent $d$

$$(e,N) = (58549809,2447482909)$$

the expansion of $\frac{e}{N}$ and its convergents will be

$$\frac{e}{N} = \bigl[\,0;\,41,\,1,\,4,\,23,\,\dots\,\bigr]$$
$$\{ c_i \}_{i{\leq}15} = \biggl\{0,\,\frac{1}{41},\,\frac{1}{42},\,\frac{5}{209},\,\frac{116}{4849},\,\dots\biggr\}$$

Using the search algorithm derived from Wiener Theorem, we notice that the fourth convergent $c_3{=}\frac{5}{209}$ is the right candidate $\widetilde{\phi}$ for the Euler function $\phi(N)$:

$$\biggl\lfloor \frac{e}{c_3} \biggr\rfloor = \biggl\lfloor \frac{58549809}{\frac{5}{209}} \biggr\rfloor = 2447382016$$

Now that we found a possible value for $\phi$, we won: the two prime factors of the RSA module have to be $60317$ and $40577$. It was too quick, wasn't it? Take a look at the paper [here](https://matteogiorgi.github.io/wiener/src/wiener_attack.pdf) or in the window below, it will satisfy any doubts and show you some magic in Wolfram Mathematica.

<object data="https://matteogiorgi.github.io/wiener/src/wiener_attack.pdf" type="application/pdf" width="100%" height="600px">
<p style="font-size:10px; color:#d0d0cc; text-align:center; border:1px solid #d0d0cc;">
  <img width=60% style="padding:30px;" src="pics/extraction.png">\
  No PDF support, <a style="color:#d0d0cc; text-decoration:underline" href="https://matteogiorgi.github.io/wiener/src/wiener_attack.pdf" title="Download PDF">click clack</a> and download the thing.
</p>
</object>

I put some effort on the appearance too: all the work is written in $\LaTeX$ with the [Tufte-LaTeX](https://github.com/Tufte-LaTeX/tufte-latex) package, plus few modifications here and there allowed me to squeeze all the content in about 20 pages.
