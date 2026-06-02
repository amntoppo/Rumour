---
trigger: model_decision
description: Use this rule when creating repositories
---

- When creating repository layer, always create an abstract class in 'domain/repositories'. Then implement those in 'data/repositories'.
- Bloc should interact with use_case only. Usecase should then interact with repository.