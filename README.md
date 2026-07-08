# Quantale-Relational Cognitive System in MeTTa

This repository contains a **Neuro-Symbolic $QRel_{[0,1]}$ Cognitive Reasoning System** built in MeTTa (Meta Type Language) using the Motto agent gateway library.

The system is designed to solve the cognitive task of reasoning about kitchen tools to fulfill the instruction: **“Measure 200 ml of water and pour it into a bowl.”**

---

## 1. Mathematical & Theoretical Backing

### $QRel_{[0,1]}$ (Quantale-Relational Category)
Our reasoning engine is mathematically backed by the category of finite sets where morphisms are weighted relations with values in the interval $[0, 1]$.
* **Compositionality:** Relations are composed using the **max-product composition** algebraic rule:
  $$\text{score}(c, a) = \max_{f \in \text{Features}} (\text{hasFeature}(c, f) \times \text{featureAffordsAction}(f, a))$$
* **The Pushout (Conceptual Blending):** The `MeasuringCup` concept is modeled as a categorical pushout colimit of a `Cup` and a `MeasuringTool` mapped through a generic space $G$ (`GeneralObject`).

---

## 2. Neuro-Symbolic Architecture

* **The LLM (Neuro) Boundary:** Gemini (`gemini-3.1-flash-lite`) is called via Motto for:
  1. Commonsense weights generation (Phase 0).
  2. Concept specification extraction (Phase 1).
  3. Intersection/Least Common Generalization $G$ calculation (Phase 2).
  4. Morphism mapping identification (Phase 3).
* **The MeTTa (Symbolic) Boundary:** All algebraic compositions, profunctor matrix propagation, axiom verification, and scoring calculations are computed purely inside MeTTa's reduction engine.

---

## 3. Codebase Structure

* `llm_based_approach/`
  * `kitchen_reasoning.metta`: The core neuro-symbolic reasoning engine. Computes weights, extracts specifications, verifies axioms, and performs max-product compositions.
  * `format_tables.metta`: Entry point script. Orchestrates execution and prints formatted Markdown tables.
* `reasoning_results.md`: Generated output report showing the reasoning trace tables.

---

## 4. How to Run

To run the pipeline and generate the tables, execute the following commands in your WSL terminal:

```bash
# 1. Set environment variables for the Gemini API Studio endpoint
export OPENAI_API_KEY="your-api-key"
export OPENAI_BASE_URL="https://generativelanguage.googleapis.com/v1beta/openai/"

# 2. Activate the conda environment
source ~/miniconda/bin/activate metta_env

# 3. Run the reasoning and table formatting script
metta /home/eyob/quantale_kitchen_system-final/llm_based_approach/format_tables.metta
```

To save the results directly to a file:
```bash
metta /home/eyob/quantale_kitchen_system-final/llm_based_approach/format_tables.metta > /home/eyob/quantale_kitchen_system-final/reasoning_results.md
```
