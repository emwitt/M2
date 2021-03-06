-- -*- coding: utf-8 -*-
--- status: TODO
--- author(s): 
--- notes: 

document { 
     Key => {gb,
	  (gb,Ideal),
	  (gb,Matrix),
	  (gb,Module),
	  [gb,Algorithm],
	  [gb, BasisElementLimit],
	  [gb,ChangeMatrix],
	  [gb,CodimensionLimit],
	  [gb,DegreeLimit],
     	  [gb,GBDegrees],
	  [gb,HardDegreeLimit],
	  [gb,Hilbert],
	  [gb,PairLimit],
	  [gb,StopBeforeComputation],
	  [gb,StopWithMinimalGenerators],
     	  [gb,Strategy],
	  [gb,SubringLimit],
	  [gb,Syzygies],
	  [gb,SyzygyLimit],
	  [gb,SyzygyRows],[gb,MaxReductionCount],
	  LinearAlgebra, Homogeneous2, Sugarless, Toric, UseSyzygies
	  },
     Headline => "compute a Gröbner basis",
     Usage => "gb I",
     Inputs => {
	  "I" => "an ideal, module, or matrix",
	  Algorithm => Symbol => {"possible values: ", TO "Homogeneous", ", ", TO "Inhomogeneous", ", ", TO "Homogeneous2", ", and ", TO "Sugarless", ".
	       Experimental options include ", TO "LinearAlgebra", " and ", TO "Toric", "."},
     	  BasisElementLimit => ZZ => "stop when this number of (nonminimal) Gröbner basis elements has been found",
	  ChangeMatrix => Boolean => { 
	       "whether to compute the change of basis matrix from Gröbner basis elements to original generators.  Use ", TO "getChangeMatrix", " to recover it."},
	  CodimensionLimit => ZZ => "stop computation once codimension of submodule of lead terms reaches this value (not functional yet)",
	  DegreeLimit => List => "stop after the Gröbner basis in this degree has been computed",
	  GBDegrees => List => "a list of positive integer weights, one for each variable in the ring, to be used for
	   organizing the computation by degrees (the 'sugar' ecart vector)",
	  HardDegreeLimit => {
	       "throws away all S-pairs of degrees beyond the limit. The computation
	       will be re-initialized if higher degrees are required."},
     	  Hilbert => {"informs Macaulay2 that this is the ", TO poincare, 
	       " polynomial, and can be used to aid in the computation of the Gröbner basis (Hilbert driven)"},
      	  MaxReductionCount => ZZ => {
	       "the maximum number of reductions of an S-pair done before requeueing it, if the 
	       ", TT "Inhomogeneous", " algorithm is in use"
	       },
	  PairLimit => ZZ => "stop after this number of spairs has been considered",
	  StopBeforeComputation => Boolean => "whether to initialize the Gröbner basis engine but return before doing any computation (useful for 
	    using or viewing partially computed Gröbner bases)",
	  StopWithMinimalGenerators => Boolean => "whether to stop as soon as the minimal set (or a trimmed set, if not homogeneous or local) of generators is known.  Intended for internal use only",
	  Strategy => {
	       "either ", TO "LongPolynomial", ", ", TO "Sort", ", or a list of these.  ", TO "LongPolynomial", ": 
	       use a geobucket data structure while reducing polynomials;
	       ", TO "Sort", ": sort the S-pairs.
	       Another symbol usable here is ", TT "UseSyzygies", ".
	       Usually S-pairs are processed degree by degree in the order that they were constructed."},
	  SubringLimit => ZZ => "stop after this number of elements of the Gröbner basis lie in the first subring",
	  Syzygies => Boolean => "whether to collect syzygies on the original generators during the computation.  Intended for internal use only",
	  SyzygyLimit => ZZ => "stop when this number of non-zero syzygies has been found",
	  SyzygyRows => ZZ => "for each syzygy and change of basis element, keep only this many rows of each syzygy"
	  },
     Outputs => {
	  GroebnerBasis => "a Gröbner basis computation object"
	  },
     "See ", TO "Gröbner bases", " for more 
     information and examples.",
     PARA{},
     "The returned value is not the Gröbner basis itself.  The
     matrix whose columns form a sorted, auto-reduced Gröbner
     basis are obtained by applying ", TO generators, " (synonym: ", TT "gens", ")
     to the result of ", TT "gb", ".",
     EXAMPLE {
	  "R = QQ[a..d]",
	  "I = ideal(a^3-b^2*c, b*c^2-c*d^2, c^3)",
	  "G = gens gb I"
	  },
     SeeAlso => {
	  "Gröbner bases",
	  groebnerBasis,
	  (generators,GroebnerBasis),
	  "gbTrace",
	  installHilbertFunction,
	  -- Mike wanted this: installGroebner,
	  gbSnapshot,
	  gbRemove
	  }
     }

document {
     Key => GroebnerBasisOptions,
     "This class is used internally to record the options used with ", TO "gb", " when the resulting Gröbner basis is
     cached inside a matrix."
     }

-- document {
--      Key => [gb,PairLimit], 
--      Headline => "stop when this number of pairs is handled",
--      TT "PairLimit", " -- keyword for an optional argument used with
--      ", TO "gb", " which specifies that the
--      computation should be stopped after a certain number of S-pairs
--      have been reduced.",
--      EXAMPLE {
-- 	  "R = QQ[x,y,z,w]",
--       	  "I = ideal(x*y-z,y^2-w-1,w^4-3)",
--       	  "gb(I, PairLimit => 1)",
--       	  "gb(I, PairLimit => 2)",
--       	  "gb(I, PairLimit => 3)"
-- 	  }
--      }

TEST ///
-- Test of various stopping conditions for GB's
R = ZZ/32003[a..j]
I = ideal random(R^1, R^{-2,-2,-2,-2,-2,-2,-2});
gbTrace=3
--time gens gb I;
I = ideal flatten entries gens I;
G = gb(I, StopBeforeComputation=>true); -- now works
m = gbSnapshot I
assert(m == 0)

I = ideal flatten entries gens I;
mI = mingens I; -- works now
assert(numgens source mI == 7)

I = ideal flatten entries gens I;
mI = trim I; -- It should stop after mingens are known to be computed.
assert(numgens source gens mI == 7)

I = ideal flatten entries gens I;
G = gb(I, DegreeLimit=>3); -- this one works
assert(numgens source gbSnapshot I == 18)
G = gb(I, DegreeLimit=>4); -- this one works
assert(numgens source gbSnapshot I == 32)
G = gb(I, DegreeLimit=>3); -- this one stops right away, as it should
assert(numgens source gbSnapshot I == 32)
G = gb(I, DegreeLimit=>5);
assert(numgens source gbSnapshot I == 46)

I = ideal flatten entries gens I;
G = gb(I, BasisElementLimit=>3); -- does the first 3, as it should
assert(numgens source gbSnapshot I == 3)
G = gb(I, BasisElementLimit=>7); -- does 4 more.
assert(numgens source gbSnapshot I == 7)

I = ideal flatten entries gens I;
G = gb(I, PairLimit=>23); -- 
assert(numgens source gbSnapshot I == 16) -- ?? is this right??

I = ideal flatten entries gens I;
hf = poincare ideal apply(7, i -> R_i^2)
G = gb(I, Hilbert=>hf); -- this works, it seems
assert(numgens source gens G == 67)

Rlex = ZZ/32003[a..j,MonomialOrder=>Eliminate 1]
IL = substitute(I,Rlex);
G = gb(IL, SubringLimit=>1, Hilbert=>hf, DegreeLimit=>2); -- SubringLimit now seems OK
G = gb(IL, SubringLimit=>1, Hilbert=>hf, DegreeLimit=>4); 
assert(numgens source selectInSubring(1,gens G) == 1)

///
