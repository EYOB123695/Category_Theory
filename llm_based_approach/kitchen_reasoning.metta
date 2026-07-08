; ============================================================================
;  QUANTALE-RELATIONAL KITCHEN COGNITIVE SYSTEM WITH CATEGORICAL PUSHOUT BLEND
;  LLM-Grounded Ecosystem Version (Uses Global metta:llm & metta:math packages)

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
   (let (Concept Cup (spec (sorts $s) (ops $o) (preds $p) (axioms $a))) (Concept Cup)
      (extract-weight-recurse $p 0 $feature)
   )
)

(= (hasFeature MeasuringTool $feature)
   (let (Concept MeasuringTool (spec (sorts $s) (ops $o) (preds $p) (axioms $a))) (Concept MeasuringTool)
      (extract-weight-recurse $p 0 $feature)
   )
)

(= (hasFeature Bowl $feature)
   (let (Concept Bowl (spec (sorts $s) (ops $o) (preds $p) (axioms $a))) (Concept Bowl)
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
   (let (Concept Cup (spec (sorts $s) (ops $o) (preds $p) (axioms $a))) (Concept Cup)
      (extract-weight-recurse $p 0 $action)
   )
)

(= (affords MeasuringTool $action)
   (let (Concept MeasuringTool (spec (sorts $s) (ops $o) (preds $p) (axioms $a))) (Concept MeasuringTool)
      (extract-weight-recurse $p 0 $action)
   )
)

(= (affords Bowl $action)
   (let (Concept Bowl (spec (sorts $s) (ops $o) (preds $p) (axioms $a))) (Concept Bowl)
      (extract-weight-recurse $p 0 $action)
   )
)

(= (affords MeasuringCup $action)
   (max2 (affords Cup $action) (affords MeasuringTool $action))
)

(= (get-measuringcup-spec)
   (Concept MeasuringCup (spec 
      (sorts (Object)) 
      (ops ()) 
      (preds (
         ((containsLiquid Object) (hasFeature MeasuringCup containsLiquid))
         ((hasVolumeMarks Object) (hasFeature MeasuringCup hasVolumeMarks))
         ((pourable Object) (hasFeature MeasuringCup pourable))
         ((handheld Object) (hasFeature MeasuringCup handheld))
         ((measureWater200ml Object) (affords MeasuringCup measureWater200ml))
         ((transferWaterToBowl Object) (affords MeasuringCup transferWaterToBowl))
      )) 
      (axioms ())
   ))
)

; 4. STATIC RELATIONS AND TARGETS
; ===============================
(= (supportsGoal measureWater200ml completeInstruction) 1.0)
(= (supportsGoal transferWaterToBowl completeInstruction) 1.0)

(= (add-relations-list $list $index)
   (if (>= $index (size-atom $list))
       True
       (let $item (index-atom $list $index)
          (let $temp (add-atom &self $item)
             (add-relations-list $list (+ $index 1))
          )
       )
   )
)

; Helper to query Gemini directly using Motto agents
(= (query-gemini $prompt)
   (let $agent (chat-gpt-agent "gemini-3.1-flash-lite" False False 30 2048)
      ($agent (user $prompt))
   )
)

; Dynamic generation of commonsense weights
!(println! ">>> [PHASE 0] Dynamically generating Commonsense Relations via Gemini...")
!(let $str (query-gemini "Generate a MeTTa list of equalities for featureAffordsAction and profunctor relations.
Use only these features: containsLiquid, hasVolumeMarks, pourable, handheld, volumeCapacity, graduatedMarks, preciseScale, holdsLiquid.
Use only these actions: measureWater200ml, transferWaterToBowl.
For featureAffordsAction, estimate the weights between 0.0 and 1.0 reflecting how much a feature supports an action.
For profunctor, align volumeCapacity with graduatedMarks (0.90), volumeCapacity with preciseScale (0.75), pourable with handheld (0.85), and holdsLiquid with graduatedMarks (0.70).
The output must be a single line of MeTTa code representing a list, like:
((= (featureAffordsAction containsLiquid transferWaterToBowl) 0.90) (= (featureAffordsAction containsLiquid measureWater200ml) 0.20) (= (profunctor volumeCapacity graduatedMarks) 0.90))
Respond with ONLY this MeTTa S-expression, nothing else. Never wrap the output in markdown backticks or code blocks.")
   (let $log (println! (concat-str "Raw Phase 0 Response: " $str))
      (let $list (_eval $str)
         (let $dummy (add-relations-list $list 0)
            (println! "; ---> Dynamic commonsense relations successfully loaded.")
         )
      )
   )
)

; 5. DYNAMIC DATA ACQUISITION & SPECIFICATION GENERATION
; ======================================================
!(println! ">>> [PHASE 1] Initializing LLM Agents...")

; Helper to generate specs using the global metta:llm package (which routes to Gemini)
(= (generate_concept_spec $c $desc)
   (llm-generate "gemini-3.1-flash-lite" (concat-str "Generate a CASL specification for concept: " (concat-str $c (concat-str ". " (concat-str $desc " Estimate appropriate weights between 0.0 and 1.0 dynamically based on real-world commonsense.")))))
)

!(let $specA (generate_concept_spec cup "Cup: A container. Focus on containsLiquid, hasVolumeMarks, pourable, handheld features and its affordances measureWater200ml, transferWaterToBowl.")
   (let $specB (generate_concept_spec measuring_tool "MeasuringTool: A device with graduations. Focus on containsLiquid, hasVolumeMarks, pourable, handheld features and its affordances measureWater200ml, transferWaterToBowl.")
      (let $u1 (add-atom &self (= (Concept Cup) $specA))
         (let $u2 (add-atom &self (= (Concept MeasuringTool) $specB))
            (println! "; ---> Specs generated and loaded for Cup and MeasuringTool.")
         )
      )
   )
)

!(let $specBowl (generate_concept_spec bowl "Bowl: A large vessel. Focus on containsLiquid, hasVolumeMarks, pourable, handheld features and its affordances measureWater200ml, transferWaterToBowl.")
   (let $u3 (add-atom &self (= (Concept Bowl) $specBowl))
      (println! "; ---> Spec generated and loaded for Bowl.")
   )
)

; 6. CATEGORICAL ARTIFACT GENERATION (The Pushout Diagram)
; ========================================================
!(println! "\n>>> [PHASE 2] Computing Least Common Generalization (G)...")
!(let* (
   ($specA (Concept Cup))
   ($specB (Concept MeasuringTool))
   ; Generate generalization using global metta:llm package
   ($specG (llm-generate "gemini-3.1-flash-lite" (concat-str "Find the Least Common Generalization specification G for: " (concat-str $specA (concat-str " and " $specB)))))
)
   (let $logG (println! "\n; ================= GENERIC SPACE G ===================")
      (let $logG2 (println! $specG)
         (let $u4 (add-atom &self (= (Concept G) $specG))
            (let $logMorph (println! "\n>>> [PHASE 3] Finding Morphisms (G -> Cup & G -> MeasuringTool)...")
               (let $mapA (llm-generate "gemini-3.1-flash-lite" (concat-str "Find the CASL morphism mapping from: " (concat-str $specG (concat-str " to: " $specA))))
                  (let $mapB (llm-generate "gemini-3.1-flash-lite" (concat-str "Find the CASL morphism mapping from: " (concat-str $specG (concat-str " to: " $specB))))
                     (let $logM1 (println! (concat-str "; Morphism G -> Cup: " $mapA))
                        (let $logM2 (println! (concat-str "; Morphism G -> MeasuringTool: " $mapB))
                           (let $logCT (println! "\n>>> [PHASE 4] Computing Symbolic Colimit (MeasuringCup Pushout Spec)...")
                              (let $colimitSpec (get-measuringcup-spec)
                                 (let $dummy (add-atom &self (= (Concept MeasuringCup) $colimitSpec))
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



