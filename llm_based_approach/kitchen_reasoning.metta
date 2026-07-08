; ============================================================================
;  QUANTALE-RELATIONAL KITCHEN COGNITIVE SYSTEM WITH CATEGORICAL PUSHOUT BLEND
;  LLM-Grounded Ecosystem Version (Uses Global metta:llm & metta:math packages)
;  100% Pure MeTTa Files in Project Directory (0% Local Python Files)
; ============================================================================
;
; Sorts:      Concept, Feature, Action, Goal
; Predicates: hasFeature, affords, supportsGoal, compatible
; Operations: blend, score
; Axiom:      containsLiquid(c) ∧ hasVolumeMarks(c) ⇒ affords(c, measure)
;
; ============================================================================

; 1. LOAD GLOBAL ECOSYSTEM PACKAGES
; =================================
!(import! &self motto)
!(import! &self metta:llm)
!(import! &self metta:math)



; 2. PARSING & EXTRACTION UTILITIES (Pure MeTTa)
; ==============================================
(= (or-func True $x) True)
(= (or-func $x True) True)
(= (or-func False False) False)

(= (is-tuple-pattern ($x)) True)
(= (is-tuple-pattern ($x $y)) True)
(= (is-tuple-pattern ($x $y $z)) True)
(= (is-tuple-pattern ($w $x $y $z)) True)
(= (is-tuple-pattern $other) False)

(= (is-expression $elem)
   (let $vals (collapse (is-tuple-pattern $elem))
      (index-atom $vals 0)
   )
)

(= (contains-query $elem $query)
   (if (== $elem $query)
       True
       (if (is-expression $elem)
           (contains-query-list $elem 0 $query)
           False
       )
   )
)

(= (contains-query-list $list $index $query)
   (if (>= $index (size-atom $list))
       False
       (if (contains-query (index-atom $list $index) $query)
           True
           (contains-query-list $list (+ $index 1) $query)
       )
   )
)

(= (extract-weight-recurse $preds $index $query)
   (if (>= $index (size-atom $preds))
       0.0
       (let $item (index-atom $preds $index)
          (let ($elem $weight) $item
             (if (contains-query $elem $query)
                 $weight
                 (extract-weight-recurse $preds (+ $index 1) $query)
             )
          )
       )
   )
)

; 3. DYNAMIC RELATION LOOKUPS (Matching directly on LLM Specs in AtomSpace)
; =======================================================================
(= (hasFeature Cup $feature)
   (match &self (Concept Cup (spec (sorts $s) (ops $o) (preds $p) (axioms $a)))
      (extract-weight-recurse $p 0 $feature)
   )
)

(= (hasFeature MeasuringTool $feature)
   (match &self (Concept MeasuringTool (spec (sorts $s) (ops $o) (preds $p) (axioms $a)))
      (extract-weight-recurse $p 0 $feature)
   )
)

(= (hasFeature Bowl $feature)
   (match &self (Concept Bowl (spec (sorts $s) (ops $o) (preds $p) (axioms $a)))
      (extract-weight-recurse $p 0 $feature)
   )
)

; PUSHOUT BLEND INTERHERITANCE FOR MeasuringCup
(= (max2 $a $b) (if (> $a $b) $a $b))
(= (hasFeature MeasuringCup $feature)
   (max2 (hasFeature Cup $feature) (hasFeature MeasuringTool $feature))
)

; AFFORDANCES LOOKUPS
(= (affords Cup $action)
   (match &self (Concept Cup (spec (sorts $s) (ops $o) (preds $p) (axioms $a)))
      (extract-weight-recurse $p 0 $action)
   )
)

(= (affords MeasuringTool $action)
   (match &self (Concept MeasuringTool (spec (sorts $s) (ops $o) (preds $p) (axioms $a)))
      (extract-weight-recurse $p 0 $action)
   )
)

(= (affords Bowl $action)
   (match &self (Concept Bowl (spec (sorts $s) (ops $o) (preds $p) (axioms $a)))
      (extract-weight-recurse $p 0 $action)
   )
)

(= (affords MeasuringCup $action)
   (max2 (affords Cup $action) (affords MeasuringTool $action))
)

; 4. STATIC RELATIONS AND TARGETS
; ===============================
(= (supportsGoal measureWater200ml completeInstruction) 1.0)
(= (supportsGoal transferWaterToBowl completeInstruction) 1.0)

(= (profunctor volumeCapacity graduatedMarks) 0.90)
(= (profunctor volumeCapacity preciseScale)   0.75)
(= (profunctor pourable      handheld)        0.85)
(= (profunctor holdsLiquid   graduatedMarks)  0.70)

(= (featureAffordsAction containsLiquid  transferWaterToBowl) 0.90)
(= (featureAffordsAction containsLiquid  measureWater200ml)   0.20)
(= (featureAffordsAction hasVolumeMarks  measureWater200ml)   1.00)
(= (featureAffordsAction hasVolumeMarks  transferWaterToBowl) 0.05)
(= (featureAffordsAction pourable        transferWaterToBowl) 0.95)
(= (featureAffordsAction pourable        measureWater200ml)   0.05)
(= (featureAffordsAction handheld        transferWaterToBowl) 0.60)
(= (featureAffordsAction handheld        measureWater200ml)   0.10)

; 5. DYNAMIC DATA ACQUISITION & SPECIFICATION GENERATION
; ======================================================
!(println! ">>> [PHASE 1] Initializing LLM Agents...")

; Helper to generate specs using the global metta:llm package
(= (generate_specs $c1 $desc1 $c2 $desc2)
   (let $specA (llm-generate "OpenAI-GPT4" (str-join ("Generate a CASL specification for concept: " $c1 " with context: " $desc1)))
      (let $specB (llm-generate "OpenAI-GPT4" (str-join ("Generate a CASL specification for concept: " $c2 " with context: " $desc2)))
         ($specA $specB)
      )
   )
)

; Fetch and generate specs for Cup and MeasuringTool
!(let $specsAB (generate_specs cup ("Cup: A container. Focus on containsLiquid (weight ~0.85), hasVolumeMarks (weight ~0.20), pourable (weight ~0.80), handheld (weight ~0.90) features and its affordances measureWater200ml (weight ~0.20), transferWaterToBowl (weight ~0.80).")
                              measuring_tool ("MeasuringTool: A device with graduations. Focus on containsLiquid (weight ~0.15), hasVolumeMarks (weight ~0.90), pourable (weight ~0.10), handheld (weight ~0.85) features and its affordances measureWater200ml (weight ~0.90), transferWaterToBowl (weight ~0.10)."))
   (let ($specA $specB) $specsAB
      (let $u1 (add-atom &self $specA)
         (let $u2 (add-atom &self $specB)
            (let $dummy (println! "; ---> Specs generated and loaded for Cup and MeasuringTool.")
               (let $dummy2 (println! (concat-str "Cup Spec: " $specA))
                  (println! (concat-str "MeasuringTool Spec: " $specB))
               )
            )
         )
      )
   )
)

; Fetch and generate spec for Bowl
!(let $specBowl (llm-generate "OpenAI-GPT4" ("Generate a CASL specification for concept: bowl. Context: Bowl: A large vessel. Focus on containsLiquid (weight ~0.95), hasVolumeMarks (weight ~0.05), pourable (weight ~0.40), handheld (weight ~0.70) features and its affordances measureWater200ml (weight ~0.05), transferWaterToBowl (weight ~0.40)."))
   (let $u3 (add-atom &self $specBowl)
      (let $dummy (println! "; ---> Spec generated and loaded for Bowl.")
         (println! (concat-str "Bowl Spec: " $specBowl))
      )
   )
)

; 6. CATEGORICAL ARTIFACT GENERATION (The Pushout Diagram)
; ========================================================
!(println! "\n>>> [PHASE 2] Computing Least Common Generalization (G)...")
!(let* (
   ($specA (match &self (Concept Cup $spec) (Concept Cup $spec)))
   ($specB (match &self (Concept MeasuringTool $spec) (Concept MeasuringTool $spec)))
   ; Generate generalization using global metta:llm package
   ($specG (llm-generate "OpenAI-GPT4" (str-join ("Find the Least Common Generalization specification G for: " $specA " and " $specB))))
)
   (let $logG (println! "\n; ================= GENERIC SPACE G ===================")
      (let $logG2 (println! $specG)
         (let $u4 (add-atom &self $specG)
            (let $logMorph (println! "\n>>> [PHASE 3] Finding Morphisms (G -> Cup & G -> MeasuringTool)...")
               ; Find morphisms using global metta:llm package
               (let $mapA (llm-generate "OpenAI-GPT4" (str-join ("Find the CASL morphism mapping from: " $specG " to: " $specA)))
                  (let $mapB (llm-generate "OpenAI-GPT4" (str-join ("Find the CASL morphism mapping from: " $specG " to: " $specB)))
                     (let $logM1 (println! "; Morphism G -> Cup:" $mapA)
                        (let $logM2 (println! "; Morphism G -> MeasuringTool:" $mapB)
                           (let $logCT (println! "\n>>> [PHASE 4] Computing Symbolic Colimit (MeasuringCup Pushout Spec)...")
                              ; Solve pushout colimit using global metta:math package
                              (let $colimitSpec (math-colimit $specA $specB $specG $mapA $mapB)
                                 (println! $colimitSpec)
                              )
                           )
                        )
                     )
                  )
               )
            )
         )
      )
   )
)

; 7. COGNITIVE REASONING & COMPOSITION
; ====================================
(= (check-axiom $c)
   (let* (
      ($w-liquid (hasFeature $c containsLiquid))
      ($w-marks  (hasFeature $c hasVolumeMarks))
      ($implied  (* $w-liquid $w-marks))
      ($actual   (affords $c measureWater200ml))
      ($satisfied (>= $actual $implied))
   )
   ($c liquid: $w-liquid marks: $w-marks implied: $implied actual: $actual satisfied: $satisfied)
   )
)

(= (composed-support $concept $action)
   (max2
      (max2
         (* (hasFeature $concept containsLiquid)
            (featureAffordsAction containsLiquid $action))
         (* (hasFeature $concept hasVolumeMarks)
            (featureAffordsAction hasVolumeMarks $action))
      )
      (max2
         (* (hasFeature $concept pourable)
            (featureAffordsAction pourable $action))
         (* (hasFeature $concept handheld)
            (featureAffordsAction handheld $action))
      )
   )
)

(= (score-object $concept)
   (let* (
      ($s-measure (affords $concept measureWater200ml))
      ($s-pour    (affords $concept transferWaterToBowl))
      ($composite (* $s-measure $s-pour))
   )
   ($concept measure: $s-measure transfer: $s-pour composite-score: $composite)
   )
)

(= (composed-score $concept)
   (let* (
      ($s-measure (composed-support $concept measureWater200ml))
      ($s-pour    (composed-support $concept transferWaterToBowl))
      ($composite (* $s-measure $s-pour))
   )
   ($concept composed-measure: $s-measure composed-transfer: $s-pour composed-score: $composite)
   )
)

(= (show-features $concept)
   (let* (
      ($f1 (hasFeature $concept containsLiquid))
      ($f2 (hasFeature $concept hasVolumeMarks))
      ($f3 (hasFeature $concept pourable))
      ($f4 (hasFeature $concept handheld))
   )
   ($concept containsLiquid: $f1 hasVolumeMarks: $f2 pourable: $f3 handheld: $f4)
   )
)

(= (show-affordances $concept)
   (let* (
      ($m (affords $concept measureWater200ml))
      ($t (affords $concept transferWaterToBowl))
   )
   ($concept measureWater200ml: $m transferWaterToBowl: $t)
   )
)

(= (show-profunctor $src $tgt)
   (let $w (profunctor $src $tgt)
      (profunctor-alignment $src $tgt compatibility: $w)
   )
)

(= (trace-path $concept $feature $action)
   (let* (
      ($r (* 1.0 (hasFeature $concept $feature)))
      ($s (* 1.0 (featureAffordsAction $feature $action)))
      ($product (* $r $s))
   )
   (path $concept via: $feature to: $action | hasFeature: $r x featureAffordsAction: $s = $product)
   )
)

(= (blend-inheritance $feature)
   (let* (
      ($blend (hasFeature MeasuringCup $feature))
      ($cup   (hasFeature Cup $feature))
      ($tool  (hasFeature MeasuringTool $feature))
   )
   (blend-feature: $feature MeasuringCup: $blend Cup: $cup MeasuringTool: $tool)
   )
)

(= (verify-blend $concept)
   (let* (
      ($liquid (* 1.0 (hasFeature $concept containsLiquid)))
      ($marks  (* 1.0 (hasFeature $concept hasVolumeMarks)))
      ($quality (* $liquid $marks))
   )
   ($concept blend-quality: $quality liquid: $liquid marks: $marks)
   )
)

(= (composed-support-summary $concept)
   (let* (
      ($sup-m (composed-support $concept measureWater200ml))
      ($sup-t (composed-support $concept transferWaterToBowl))
   )
   ($concept support-measure: $sup-m support-transfer: $sup-t)
   )
)



