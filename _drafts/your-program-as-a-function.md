---
title: Your program as a function
date: 2019-09-11
layout: post
---

Describing programs to fellow programmers is, somewhat surprisingly, tremendously
difficult. Onboarding colleagues unfamiliar to a program is always a mix of verbal and non-verbal
documentation, interspersed with documenting the *documentation*, showing code, and so on.
Questions like *"What does it *do*?" are often omitted by the new novice, now dazed and confused
from exposure to vast unfamiliarity. 

That question is deceptively simple, but difficult to answer *simply*. What does [Kafka](http://kafka.apache.org/) do? It's a message broker based on a distributed commit log. Was that correct? Probably not, but it's *close enough*. It's not factually wrong, it's a simplification, therefore, a compromise.

What if we could capture these deceptively simple explanations as *functions*? In functional programming,
where everything *is* a function, this is actually possible. Here's a function that captures the notion 
of validating a shopping basket:

```haskell
type ValidateBasket = Basket -> Set ValidationRule -> BasketValidation
```

From this parameter list we can see that this is a function that takes a
`Basket` as an input, a set of `ValidationRule`s, and produces a
`BasketValidation`. That starts from the top-level abstraction. Going deeper,
we find more type aliases, explaining what is a `Basket`, a `ValidationRule`,
and a `BasketValidation`. But at the *surface*, the type alias works as an
abstraction meant to simplify the details away. And that is precisely the objective:
to make complex programs look simpler and more approachable.


