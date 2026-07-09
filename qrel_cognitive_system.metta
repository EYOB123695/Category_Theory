; ============================================================================
;  QUANTALE-RELATIONAL COGNITIVE SYSTEM WITH CATEGORICAL PUSHOUT BLEND
;  Kitchen Tool Reasoning: "Measure 200 ml of water and pour it into a bowl."
; ============================================================================

!(import! &self motto)

; ============================================================================
;  1. CASL-STYLE SPECIFICATION (Sorts, Predicates, Operations, Axioms)
; ============================================================================
;
; spec KITCHEN_COGNITIVE_SYSTEM =
;   sorts
;     Concept, Feature, Action, Goal
;
;   preds
;     hasFeature : Concept * Feature -> [0, 1]
;     affords : Concept * Action -> [0, 1]
;     featureAffordsAction : Feature * Action -> [0, 1]
;     profunctor : Feature * Feature -> [0, 1]
;     supportsGoal : Action * Goal -> [0, 1]
;     compatible : Feature * Feature -> [0, 1]
;
;   ops
;     blend : Concept * Concept * Concept -> Concept   -- blend(A, B, G) along generic space G
;     score : Concept * Goal -> [0, 1]                 -- max-product composite score
;
;   axioms
;     -- Axiom: containers with volume marks afford measuring volume
;     forall c : Concept .
;       affords(c, measureWater200ml) >= hasFeature(c, containsLiquid) * hasFeature(c, hasVolumeMarks)
;
; ============================================================================

; Helper functions
(= (max2 $a $b) (if (> $a $b) $a $b))


; ============================================================================
;  2. DEFINITIONS OF CONCEPTS AND FEATURE WEIGHTS (QRel [0, 1] Objects)
; ============================================================================

; Cup
(= (hasFeature Cup containsLiquid) 0.95)
(= (hasFeature Cup hasVolumeMarks) 0.60)
(= (hasFeature Cup pourable) 0.90)
(= (hasFeature Cup handheld) 0.95)

; MeasuringTool
(= (hasFeature MeasuringTool containsLiquid) 0.90)
(= (hasFeature MeasuringTool hasVolumeMarks) 1.00)
(= (hasFeature MeasuringTool pourable) 0.80)
(= (hasFeature MeasuringTool handheld) 0.90)

; Bowl
(= (hasFeature Bowl containsLiquid) 0.95)
(= (hasFeature Bowl hasVolumeMarks) 0.40)
(= (hasFeature Bowl pourable) 0.80)
(= (hasFeature Bowl handheld) 0.90)

; Generic Space G: VolumeObject
(= (hasFeature VolumeObject containsLiquid) 0.90)
(= (hasFeature VolumeObject hasVolumeMarks) 0.60)
(= (hasFeature VolumeObject pourable) 0.80)
(= (hasFeature VolumeObject handheld) 0.90)


; ============================================================================
;  3. CATEGORICAL PUSHOUT MAPPINGS (Morphisms & supremum blend)
; ============================================================================
;
;  Let G = VolumeObject be the generic space representing basic volume capability.
;  We have morphisms m1: G -> Cup and m2: G -> MeasuringTool.
;  In QRel [0,1], a morphism G -> C is a weighted relation. Here, G features map
;  to corresponding concept features.
;  The morphism condition requires: hasFeature(G, f) <= hasFeature(Concept, f)
;
;  Verification of Morphisms:
;  m1: G -> Cup
;    containsLiquid: 0.90 <= 0.95 (True)
;    hasVolumeMarks: 0.60 <= 0.60 (True)
;    pourable:        0.80 <= 0.90 (True)
;    handheld:        0.90 <= 0.95 (True)
;  m2: G -> MeasuringTool
;    containsLiquid: 0.90 <= 0.90 (True)
;    hasVolumeMarks: 0.60 <= 1.00 (True)
;    pourable:        0.80 <= 0.80 (True)
;    handheld:        0.90 <= 0.90 (True)
;
;  MeasuringCup is the Pushout (Colimit Blend) of Cup and MeasuringTool over G.
;  Under the colimit in QRel_[0,1], feature weights are computed as the supremum:
;    hasFeature(MeasuringCup, f) = max(hasFeature(Cup, f), hasFeature(MeasuringTool, f))

(= (hasFeature MeasuringCup $feature)
   (max2 (hasFeature Cup $feature) (hasFeature MeasuringTool $feature))
)


; ============================================================================
;  4. ACTION AFFORDANCES AND PROFUNCTOR MATRIX
; ============================================================================

; Direct affordances (Concept -> Action)
(= (affords Cup measureWater200ml) 0.75)
(= (affords Cup transferWaterToBowl) 0.85)

(= (affords MeasuringTool measureWater200ml) 0.95)
(= (affords MeasuringTool transferWaterToBowl) 0.85)

(= (affords Bowl measureWater200ml) 0.60)
(= (affords Bowl transferWaterToBowl) 0.85)

(= (affords MeasuringCup $action)
   (max2 (affords Cup $action) (affords MeasuringTool $action))
)

; Feature affordance weights (Feature -> Action)
(= (featureAffordsAction containsLiquid transferWaterToBowl) 0.90)
(= (featureAffordsAction containsLiquid measureWater200ml) 0.30)
(= (featureAffordsAction hasVolumeMarks transferWaterToBowl) 0.40)
(= (featureAffordsAction hasVolumeMarks measureWater200ml) 0.95)
(= (featureAffordsAction pourable transferWaterToBowl) 0.95)
(= (featureAffordsAction pourable measureWater200ml) 0.50)
(= (featureAffordsAction handheld transferWaterToBowl) 0.80)
(= (featureAffordsAction handheld measureWater200ml) 0.70)

; Profunctor matrix: Graded compatibility (alignment) between Cup and MeasuringTool features
; Identity alignments (compatibility = 1.0)
(= (profunctor containsLiquid containsLiquid) 1.00)
(= (profunctor hasVolumeMarks hasVolumeMarks) 1.00)
(= (profunctor pourable pourable) 1.00)
(= (profunctor handheld handheld) 1.00)

; Graded alignments between different features
(= (profunctor containsLiquid pourable) 0.85)
(= (profunctor pourable handheld) 0.80)
(= (profunctor containsLiquid hasVolumeMarks) 0.85)
(= (profunctor hasVolumeMarks containsLiquid) 0.85)
(= (profunctor containsLiquid handheld) 0.70)
(= (profunctor hasVolumeMarks pourable) 0.30)
(= (profunctor hasVolumeMarks handheld) 0.50)


; ============================================================================
;  5. ALGEBRAIC REASONING & COMPOSITION
; ============================================================================
;
;  Max-Product composition of relation R (Concept -> Feature) and S (Feature -> Action):
;  (R o S)(c, a) = max_{f} (R(c, f) * S(f, a))

(= (composed-support $concept $action)
   (max2
      (max2
         (* (hasFeature $concept containsLiquid) (featureAffordsAction containsLiquid $action))
         (* (hasFeature $concept hasVolumeMarks) (featureAffordsAction hasVolumeMarks $action))
      )
      (max2
         (* (hasFeature $concept pourable) (featureAffordsAction pourable $action))
         (* (hasFeature $concept handheld) (featureAffordsAction handheld $action))
      )
   )
)

; Composite score for instruction (measure and transfer)
; score(object, instruction) = score(measure) * score(transfer)
(= (composed-score $concept)
   (let* (
      ($s-measure (composed-support $concept measureWater200ml))
      ($s-pour    (composed-support $concept transferWaterToBowl))
      ($composite (* $s-measure $s-pour))
   )
   $composite
   )
)


; ============================================================================
;  6. OUTPUT FORMATTING & PRINTER UTILITIES
; ============================================================================

(= (print-feature-row $concept)
   (let* (
      ($f1 (hasFeature $concept containsLiquid))
      ($f2 (hasFeature $concept hasVolumeMarks))
      ($f3 (hasFeature $concept pourable))
      ($f4 (hasFeature $concept handheld))
      ($r1 (concat-str "| **" $concept))
      ($r2 (concat-str $r1 "** | "))
      ($r3 (concat-str $r2 $f1))
      ($r4 (concat-str $r3 " | "))
      ($r5 (concat-str $r4 $f2))
      ($r6 (concat-str $r5 " | "))
      ($r7 (concat-str $r6 $f3))
      ($r8 (concat-str $r7 " | "))
      ($r9 (concat-str $r8 $f4))
      ($row (concat-str $r9 " |"))
   )
   (println! $row)
   )
)

(= (print-features-table)
   (let* (
      ($_1 (println! "| Concept | containsLiquid | hasVolumeMarks | pourable | handheld |"))
      ($_2 (println! "| :--- | :---: | :---: | :---: | :---: |"))
      ($_3 (print-feature-row Cup))
      ($_4 (print-feature-row MeasuringTool))
      ($_5 (print-feature-row Bowl))
      ($_6 (print-feature-row MeasuringCup))
   )
   ()
   )
)

(= (print-affordance-row $concept)
   (let* (
      ($m (affords $concept measureWater200ml))
      ($t (affords $concept transferWaterToBowl))
      ($r1 (concat-str "| **" $concept))
      ($r2 (concat-str $r1 "** | "))
      ($r3 (concat-str $r2 $m))
      ($r4 (concat-str $r3 " | "))
      ($r5 (concat-str $r4 $t))
      ($row (concat-str $r5 " |"))
   )
   (println! $row)
   )
)

(= (print-affordances-table)
   (let* (
      ($_1 (println! "| Concept | measureWater200ml | transferWaterToBowl |"))
      ($_2 (println! "| :--- | :---: | :---: |"))
      ($_3 (print-affordance-row Cup))
      ($_4 (print-affordance-row MeasuringTool))
      ($_5 (print-affordance-row Bowl))
      ($_6 (print-affordance-row MeasuringCup))
   )
   ()
   )
)

(= (print-profunctor-row $src $tgt)
   (let* (
      ($w (profunctor $src $tgt))
      ($r1 (concat-str "| " $src))
      ($r2 (concat-str $r1 " | "))
      ($r3 (concat-str $r2 $tgt))
      ($r4 (concat-str $r3 " | **"))
      ($r5 (concat-str $r4 $w))
      ($row (concat-str $r5 "** |"))
   )
   (println! $row)
   )
)

(= (print-profunctors-table)
   (let* (
      ($_1 (println! "| Source Feature (Cup) | Target Feature (MeasuringTool) | Compatibility |"))
      ($_2 (println! "| :--- | :--- | :---: |"))
      ($_3 (print-profunctor-row containsLiquid containsLiquid))
      ($_4 (print-profunctor-row hasVolumeMarks hasVolumeMarks))
      ($_5 (print-profunctor-row pourable pourable))
      ($_6 (print-profunctor-row handheld handheld))
      ($_7 (print-profunctor-row containsLiquid pourable))
      ($_8 (print-profunctor-row pourable handheld))
      ($_9 (print-profunctor-row containsLiquid hasVolumeMarks))
      ($_10 (print-profunctor-row hasVolumeMarks containsLiquid))
      ($_11 (print-profunctor-row containsLiquid handheld))
      ($_12 (print-profunctor-row hasVolumeMarks pourable))
      ($_13 (print-profunctor-row hasVolumeMarks handheld))
   )
   ()
   )
)

(= (print-axiom-row $c)
   (let* (
      ($w-liquid (hasFeature $c containsLiquid))
      ($w-marks  (hasFeature $c hasVolumeMarks))
      ($implied  (* $w-liquid $w-marks))
      ($actual   (affords $c measureWater200ml))
      ($satisfied (>= $actual $implied))
      ($r1 (concat-str "| **" $c))
      ($r2 (concat-str $r1 "** | "))
      ($r3 (concat-str $r2 $w-liquid))
      ($r4 (concat-str $r3 " | "))
      ($r5 (concat-str $r4 $w-marks))
      ($r6 (concat-str $r5 " | "))
      ($r7 (concat-str $r6 $implied))
      ($r8 (concat-str $r7 " | "))
      ($r9 (concat-str $r8 $actual))
      ($r10 (concat-str $r9 " | **"))
      ($r11 (concat-str $r10 $satisfied))
      ($row (concat-str $r11 "** |"))
   )
   (println! $row)
   )
)

(= (print-axioms-table)
   (let* (
      ($_1 (println! "| Concept | containsLiquid | hasVolumeMarks | Implied Affordance | Actual Affordance | Satisfied? |"))
      ($_2 (println! "| :--- | :---: | :---: | :---: | :---: | :---: |"))
      ($_3 (print-axiom-row Cup))
      ($_4 (print-axiom-row MeasuringTool))
      ($_5 (print-axiom-row Bowl))
      ($_6 (print-axiom-row MeasuringCup))
   )
   ()
   )
)

(= (print-composed-score-row $concept)
   (let* (
      ($s-measure (composed-support $concept measureWater200ml))
      ($s-pour    (composed-support $concept transferWaterToBowl))
      ($composite (* $s-measure $s-pour))
      ($r1 (concat-str "| **" $concept))
      ($r2 (concat-str $r1 "** | "))
      ($r3 (concat-str $r2 $s-measure))
      ($r4 (concat-str $r3 " | "))
      ($r5 (concat-str $r4 $s-pour))
      ($r6 (concat-str $r5 " | **"))
      ($r7 (concat-str $r6 $composite))
      ($row (concat-str $r7 "** |"))
   )
   (println! $row)
   )
)

(= (print-composed-scores-table)
   (let* (
      ($_1 (println! "| Concept | Composed Measure | Composed Transfer | Composed Score |"))
      ($_2 (println! "| :--- | :---: | :---: | :---: |"))
      ($_3 (print-composed-score-row Cup))
      ($_4 (print-composed-score-row MeasuringTool))
      ($_5 (print-composed-score-row Bowl))
      ($_6 (print-composed-score-row MeasuringCup))
   )
   ()
   )
)

(= (print-trace-row $concept $feature $action)
   (let* (
      ($r (hasFeature $concept $feature))
      ($s (featureAffordsAction $feature $action))
      ($product (* $r $s))
      ($r1 (concat-str "| " $concept))
      ($r2 (concat-str $r1 " | "))
      ($r3 (concat-str $r2 $feature))
      ($r4 (concat-str $r3 " | "))
      ($r5 (concat-str $r4 $action))
      ($r6 (concat-str $r5 " | "))
      ($r7 (concat-str $r6 $r))
      ($r8 (concat-str $r7 " * "))
      ($r9 (concat-str $r8 $s))
      ($r10 (concat-str $r9 " = "))
      ($r11 (concat-str $r10 $product))
      ($row (concat-str $r11 " |"))
   )
   (println! $row)
   )
)

(= (print-trace-table-measuringcup)
   (let* (
      ($_1 (println! "| Concept | Via Feature | To Action | calculation |"))
      ($_2 (println! "| :--- | :--- | :--- | :--- |"))
      ($_3 (print-trace-row MeasuringCup containsLiquid measureWater200ml))
      ($_4 (print-trace-row MeasuringCup hasVolumeMarks measureWater200ml))
      ($_5 (print-trace-row MeasuringCup pourable measureWater200ml))
      ($_6 (print-trace-row MeasuringCup handheld measureWater200ml))
      ($_7 (print-trace-row MeasuringCup containsLiquid transferWaterToBowl))
      ($_8 (print-trace-row MeasuringCup hasVolumeMarks transferWaterToBowl))
      ($_9 (print-trace-row MeasuringCup pourable transferWaterToBowl))
      ($_10 (print-trace-row MeasuringCup handheld transferWaterToBowl))
   )
   ()
   )
)

(= (print-blend-row $concept)
   (let* (
      ($liquid (hasFeature $concept containsLiquid))
      ($marks  (hasFeature $concept hasVolumeMarks))
      ($quality (* $liquid $marks))
      ($r1 (concat-str "| **" $concept))
      ($r2 (concat-str $r1 "** | "))
      ($r3 (concat-str $r2 $liquid))
      ($r4 (concat-str $r3 " | "))
      ($r5 (concat-str $r4 $marks))
      ($r6 (concat-str $r5 " | **"))
      ($r7 (concat-str $r6 $quality))
      ($row (concat-str $r7 "** |"))
   )
   (println! $row)
   )
)

(= (print-blend-verification-table)
   (let* (
      ($_1 (println! "| Concept | liquid | marks | Blend Quality |"))
      ($_2 (println! "| :--- | :---: | :---: | :---: |"))
      ($_3 (print-blend-row Cup))
      ($_4 (print-blend-row MeasuringTool))
      ($_5 (print-blend-row Bowl))
      ($_6 (print-blend-row MeasuringCup))
   )
   ()
   )
)

(= (print-inheritance-row $feature)
   (let* (
      ($blend (hasFeature MeasuringCup $feature))
      ($cup   (hasFeature Cup $feature))
      ($tool  (hasFeature MeasuringTool $feature))
      ($r1 (concat-str "| " $feature))
      ($r2 (concat-str $r1 " | **"))
      ($r3 (concat-str $r2 $blend))
      ($r4 (concat-str $r3 "** | "))
      ($r5 (concat-str $r4 $cup))
      ($r6 (concat-str $r5 " | "))
      ($r7 (concat-str $r6 $tool))
      ($row (concat-str $r7 " |"))
   )
   (println! $row)
   )
)

(= (print-blend-inheritance-table)
   (let* (
      ($_1 (println! "| Feature | MeasuringCup (Blend) | Cup (Source) | MeasuringTool (Source) |"))
      ($_2 (println! "| :--- | :---: | :---: | :---: |"))
      ($_3 (print-inheritance-row containsLiquid))
      ($_4 (print-inheritance-row hasVolumeMarks))
      ($_5 (print-inheritance-row pourable))
      ($_6 (print-inheritance-row handheld))
   )
   ()
   )
)

; ============================================================================
;  7. EXECUTION
; ============================================================================

!(println! "================================================================================")
!(println! " QUANTALE-RELATIONAL KITCHEN COGNITIVE SYSTEM (MeTTa 0.2.10 Native Execution)")
!(println! "================================================================================")

!(println! "")
!(println! "PHASE 1: CONCEPT x FEATURE TABLE")
!(print-features-table)

!(println! "")
!(println! "PHASE 2: CONCEPT x ACTION TABLE (DIRECT AFFORDANCES)")
!(print-affordances-table)

!(println! "")
!(println! "PHASE 3: PROFUNCTOR ALIGNMENT MATRIX")
!(print-profunctors-table)

!(println! "")
!(println! "PHASE 4: SEMANTIC AXIOM VERIFICATION")
!(print-axioms-table)

!(println! "")
!(println! "PHASE 5: MAX-PRODUCT COMPOSED SCORING")
!(print-composed-scores-table)

!(println! "")
!(println! "PHASE 6: DETAILED MAX-PRODUCT TRACE (MeasuringCup)")
!(print-trace-table-measuringcup)

!(println! "")
!(println! "PHASE 7: PUSHOUT BLEND VERIFICATION & FEATURE INHERITANCE")
!(print-blend-verification-table)
!(println! "")
!(print-blend-inheritance-table)

!(println! "")
!(println! "PHASE 8: COGNITIVE SYSTEM INTERPRETATION & DECISION")
!(println! "---------------------------------------------------")
!(println! "Target Instruction: 'Measure 200 ml of water and pour it into a bowl.'")
!(println! "Required actions: measureWater200ml AND transferWaterToBowl.")
!(println! "Compositional scoring rule: score(object) = composed-support(object, measure) * composed-support(object, transfer)")
!(println! "")
!(println! "Resulting Composed Scores:")
!(println! "- Cup:          0.665 * 0.855 = 0.568575")
!(println! "- Bowl:         0.630 * 0.855 = 0.538650")
!(println! "- MeasuringTool: 0.950 * 0.810 = 0.769500")
!(println! "- MeasuringCup:  0.950 * 0.855 = 0.812250  <-- WINNER!")
!(println! "")
!(println! "EXPLANATION:")
!(println! "MeasuringCup is the optimal tool because it is the pushout blend of Cup and MeasuringTool along the VolumeObject interface.")
!(println! "As a pushout blend, MeasuringCup inherits the strong containment/pouring capability of a Cup (pourable=0.9, handheld=0.95)")
!(println! "and the strong measurement capability of a MeasuringTool (hasVolumeMarks=1.0).")
!(println! "Alternatives lose support on one of the required actions:")
!(println! "- Cup lacks precise volume markings (hasVolumeMarks=0.6), yielding poor measurement performance.")
!(println! "- MeasuringTool is not optimized for containment and pouring (pourable=0.8, handheld=0.9), yielding poor transfer performance.")
!(println! "- Bowl completely lacks volume marks (hasVolumeMarks=0.4), yielding very poor measurement performance.")
!(println! "Therefore, MeasuringCup preserves both roles, achieving the highest composite score of 0.81225.")
