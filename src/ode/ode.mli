(*
 * OWL - OCaml Scientific and Engineering Computing
 * OWL-ODE - Ordinary Differential Equation Solvers
 *
 * Copyright (c) 2019 Ta-Chu Kao <tck29@cam.ac.uk>
 * Copyright (c) 2019 Marcello Seri <m.seri@rug.nl>
 *)

 (** Owl_ode is a lightweight package for solving ordinary differential
    equations. Built on top of Owl’s numerical library, Owl_ode was
    designed with extensibility and ease of use in mind and includes a
    number of classic ode solvers (e.g. Euler and Runge-Kutta, in both
    adaptive and fixed-step variants) and symplectic sovlers (e.g.
    Leapfrog), with more to come.
 
    This library provides a collection of solvers for the
    initial value problem for ordinary differential equation systems.
    
    You can jump to the interface of the {!lib}.

    {2 Example of use}

    Let's solve the linear initial value problem ∂ₜ y = A y, with
    y(t₀) = y₀. Say that A is the matrix ((1;-1); (2;3)), and the
    initial conditions are given by y(0) = (-1;1).

    We begin by defining a function f(y, t) that corresponds to
    the RHS of the differential equation
    {[
    let f y t = 
      let a = [|[|1.; -1.|];
               [|2.; -3.|]|]
              |> Owl.Mat.of_arrays
      in
      Owl.Mat.(a *@ y)
    ]}
    and the initial conditions y0
    {[
    let y0 = Mat.of_array [|-1.; 1.|] 2 1
    ]}

    Before being able to actually call the integrating function,
    we need to define the time specification for the problem at
    hand
    {[
    let tspec = Owl_ode.Types.(T1 {t0 = 0.; duration = 2.; dt=1E-3})
    ]}
    This in particular allows us to specify also that t₀=0.
    Here, we construct a record using the constructor {!Owl_ode.Types.T1},
    which includes the start time t₀, the time duration for the
    numerical solution, and a step size dt.
    
    Finally we can call
    {[
      let ts, ys = Owl_ode.odeint (module Owl_ode.Native.D.RK4) f y0 tspec () 
    ]}
    to get an array with the approximate value of the vector y
    at the times ts. As you can see from the snippet above, you
    have to specify the algorithm used for the integration by 
    providing its module in the function call. Here, we integrated
    the dynamical system with {!Owl_ode.Native.D.RK4}, a fixed-step
    double-precision Runge-Kutta solver. In Owl_ode, we provide
    a number of ocaml-based double-precision solvers in the
    {!Owl_ode.Native.D} modeuoe and single-precision ones in
    {!Owl_ode.Native.S}. Additional integrators are provided by
    external and third party libraries.

    The solution can be easily plotted using {!Owl_plplot} or any
    other owl-compatible plotting library, for example
    {[
    let open Owl_plplot in
    let h = Plot.create "myplot.png" in
    Plot.plot ~h ~spec:[ RGB (0,0,255); LineStyle 1 ] ts (Mat.col ys 0);
    Plot.output h;
    ]}

    You can refer to the examples in the source repository for
    more complex examples.

   @version 0.1
   @author Marcello Seri and Ta-Chu Kao
 *)

(* TODO: move complex examples in the documentation *)

(** {2:lib Ode library} *)

val odeint : 
  (module Types.SolverT with type output = 'a and type s = 'b and type t = 'c) ->
  ('b -> float -> 'c) ->
  'b ->
  Types.tspec_t ->
  unit ->
  'a
(** [odeint (module Solver) f y0 timespec ()] numerically integrates
    an initial value problem for a system of ODEs given an initial value:

    ∂ₜ y = f(y, t)
    
    y(t₀) = y₀

    Here t is a one-dimensional independent variable (time), y(t) is an
    n-dimensional vector-valued function (state), and the n-dimensional
    vector-valued function f(y, t) determines the differential equations.
    
    The goal is to find y(t) approximately satisfying the differential
    equations, given an initial value y(t₀)=y₀. The time t₀ is passed as
    part of the timespec, that includes also the final integration time
    and a time step. Refer to {!Owl_ode.Types.tspec_t} for further
    information.

    The native ocaml solvers provided by Owl_ode in both single and
    double precision can be found in {!Owl_ode.Native}, respectively
    in the {!Owl_ode.Native.S} and {!Owl_ode.Native.D} modules. These
    provide multiple single-step and adaptive implementations.

    Symplectic methods for separable Hamiltopnian are alse available
    and can be found in {!Owl_ode.Symplectic.S} and {!Owl_ode.Symplectic.D}. 
*)