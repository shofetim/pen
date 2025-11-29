(import spork/htmlgen)

(var missing-fields-counter 0)

(def all-models
  "Will store models that will be used in various places throughout the documentation"
  @[])

(defn s-format [pat & args]
  (defn- flatn [thing]
    (if (get {:tuple true :array true} (type thing))
      (string/join thing)
      (string thing)))

  (string (string/format pat ;(map flatn args)) "\n"))

(each tag
    ["center" "tr" "td" "th"]
  (defglobal tag (fn [content] (s-format "@%s{%s}" symbol content))))

(defn tag
  "Wrap some content in an html tag. If you need attributes or other properties,
  you may want to use raw HTML via the html function."
  [name content]
  (s-format "
// todo
@%s{%s}

" symbol content))

(defn blockquote [content]
  (s-format "#quote[
%s
]" content))

(defn dl [content] "\n")
(defn dt [content] (s-format "/ %s" content))
(defn dd [content] content)
(defn ul [content] (s-format "%s" content))
(defn ol [content] "\n")
(defn li [content] (s-format "- %s" content))
(defn p [content] (s-format "\n%s\n" content))
(defn em [content] (s-format "_%s_" content))
(defn strong [content] (s-format "*%s*" content))
(defn u [content] (s-format "#underline[%s]" content))
(defn q [content] (s-format "#quote[%s]" content))
(defn pre [content] (s-format "`%s`" content))
(defn sub [content] (s-format "#sub[%s]" content))
(defn sub [content] (s-format "#super[%s]" content))
(defn h1 [content] (s-format "= %s" content))
(defn h2 [content] (s-format "== %s" content))
(defn h3 [content] (s-format "=== %s" content))
(defn h4 [content] (s-format "==== %s" content))
(defn h5 [content] (s-format "===== %s" content))

(defn index [content]              # todo need to rework when know more of typst
  # [:ul {:class "index"} content]
  (s-format
   "#index[
%s
]" content))

(defn index-item [link title date] # todo need to rework when know more of typst
  # [:li
  #    [:a {:href link :class "index-item"}
  #     [:span {:class "index-item-title"} title]
  #     [:span {:class "index-dots"} ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."]
  #     [:span {:class "index-item-date"} date]]]
  (s-format "#index-item(link title data)"))

(defn aside                        # todo need to rework when know more of typst
  [content]
  [:div {:class "aside-wrapper" :onclick "showAside(window.event)"}
   [:aside content]])

(defn aside-l                      # todo need to rework when know more of typst
  [content]
  [:div {:class "aside-wrapper" :onclick "showAside(window.event)"}
   [:aside {:class "left-aside" } content]])

(defn hr [&opt content] "#line(length: 100%)")

(defn bigger [content]             # todo need to rework when know more of typst
  [:span {:style "font-size:1.61803398875em;"} content])

(defn smaller [content]            # todo need to rework when know more of typst
  [:span {:style "font-size:0.61803398875em;"} content])

(defn image [src] (s-format `#image("%s")`))
(defn img [src] (image src))

(defn html [source]
  (s-format
   "//todo
```html
%s
```" source))

(defn page-break [_] "#pagebreak()")

(defn codeblock [content]
  (s-format
   "```\n
%s\n
```" (string/trim content)))

(defn code [content] (s-format "`%s`" content))

(defn comment [content] (s-format "/* %s */" content))
(defn private [content] (s-format "/* %s */" content))

(defn title [content]
  (s-format `#title("%s")` content))

(defn entry [date-string content]
  (s-format
   "= %s
%s
" date-string content))

(defn link [url &opt content]
  (s-format `#link("%s")[%s]` url (or content url)))

(defn ntab # typst doesn't have the same concept
  "A link that opens in a new tab"
  [url &opt content]
  (link url content))

(defn published #todo
  [content]
  # [:span {:class "published"} content]
  (s-format "#published[%s]" content))

(defn make-id
  "https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/id"
  [content]
  (peg/replace-all
   ~(some :W)
   (fn [match]
     (if (or (> (length match) 1) (= match " "))
       "-" ""))
   (first content)))

(defn chapter [content] # todo
  # [:h2 {:id (make-id content)} content]
  (s-format `== %s` content))

(defn numeric-id
  [section &opt subsection subsubsection]
  (string/join
    (map string
         (filter |(not (nil? $))
                 [section subsection subsubsection])) "."))

(defn anchor [content]
  (link (string "#" (make-id content)) content))

(var section-counter 1)
(var subsection-counter 1)
(var subsubsection-counter 1)

(defn section [content] (s-format "= %s" content))
(defn subsection [content] (s-format "== %s" content))
(defn subsubsection [content] (s-format "=== %s" content))

(defn pikchr #todo could/should we call out to pikchr to convert?
  `Process block through Pikchr returning SVG`
  [str]
  (s-format "```pikchr
%s
```" str))

(defn pipe-table
  ```
  Creates a table from data where fields are seperated by the pipe (|)
  symbol and rows are seperated by newlines. Basically markdown pipe
  tables. The first row is used as a header.
  ```
  [content]
  (let [data (map |(array/slice (string/split "|" $) 1 -2)
                  (string/split "\n" content))
        data (filter |(not (empty? $)) data)
        head (first data)
        body (array/remove data 0 2)]
    [:table
     [:thead [:tr (map (fn [i] [:th i]) head)]]
     [:tbody
        (map
         (fn [row]
           [:tr (map (fn [i] [:td i]) row)])
         body)]]))

(defn verbatim [content] content)

(defn- object-name              # not implementing
  [content]
  (let [field (if (string? content) content (first content))]
    (if (string/has-prefix? ":" field) (string/slice field 1) field)))

(defn get-stored-model          # not implementing
  [reference]
  (let [model (find |(= reference (first $)) all-models)]
    (if (and  (nil? model)
              (not (= "Attachments" (string reference)))
              (not (= "Open_Activities" (string reference)))
              (not (= "Activity_History" (string reference)))
              (not (= "Notes&Attachments" (string reference)))
              (not (= "Notes" (string reference))))
      (print (s-format "%d - Model for %s not present in the documentation" (set missing-fields-counter (inc missing-fields-counter)) reference)))
    model))

(defn get-referenced-field-name # not implementing
  [api-name reference]
  (if (nil? reference)
    api-name
    (do
      (def referenced-field (find |(= api-name (get $ 0)) reference))
      (if (nil? referenced-field)
        (do
          (print (s-format "%d - Field %s not present in the model %s" (set missing-fields-counter (inc missing-fields-counter)) api-name (reference 0)))
          api-name)
        (get referenced-field 1)))))

(defn f                         # not implementing
  "Field name; link to field definition in @model"
  [content]
  (let [field (object-name content)
        full-field-name (if (string? content) content (first content))
        object-name ((string/split "." full-field-name) 0)
        stored-object (get-stored-model (parse object-name))
        stored-field (get-referenced-field-name (parse full-field-name) stored-object)]
    [:a {:class "object" :href (string "#" field)} field]))

(defn o                         # not implementing
  [content]
  (let [object (object-name content)
        full-object-name (if (string? content) content (first content))
        stored-object (get-stored-model (parse full-object-name))]
    [:a {:class "object" :href (string "#" object)} object]))

##################################################################################
# Model

(defn- render-extra
  [field-type extra]
  (if (not (empty? extra))
    (if (or (= field-type "Master-Detail") (= field-type "Lookup"))
      [:a {:class "object" :href (string "#" extra)} extra]
      [:ul
        (map |[:li $] (string/split ";" extra))])))

(defn- render-field
  [field]
  (let [field-name (string (first field))
        id (object-name field-name)
        field-label (string (get field 1))
        field-type (string (get field 2))
        extra (string (get field 3))]
    [:tr
      [:td {} field-label]
      [:td {:id id :class "max-width"} field-name]
      [:td field-type]
      [:td {:class "max-width"} (render-extra field-type extra)]]))

(defn model
  [content &opt store]
  (let [parsed (parse content)
        object (object-name (string (first parsed)))
        fields (array/slice parsed 2)]
    (if-not (nil? store)
      (array/push all-models (parse content))
      [:div {:id object :class "model"}
        [:span {:class "object-display"} object]
        [:table
          [:thead
            [:th "Label"]
            [:th "API Name"]
            [:th "Type"]
            [:th "Extra"]]
          [:tbody
            (map |(render-field $) fields)]]])))

##################################################################################
# Layout

(defn render-tabs
  [tabs]
  (let [labels (map |($ :label) tabs)]
    [:div
      [:span {:class "layout-tabs-labels"}
        (map (fn [l] [:span {:class (if (= l "Details") "layout-tab-label selected" "layout-tab-label")
                      :onclick "changeTab(window.event)"} l]) labels)]
      [:span {:class "layout-tabs-contents"}
        (map (fn [t] [:span {:class "layout-tab-content" :style (if-not (= "Details" (t :label)) "display:none")} (t :content)]) tabs)]]))

(defn render-layout-related
  [related reference]
  (def object-name (if (string? (get reference 1)) (get reference 1) (string related)))
  [:span {:class "layout-related"}
    [:span {:class "layout-related-new-opportunity"}
      [:svg {:xmlns "http://www.w3.org/2000/svg"
            :x "0px"
            :y "0px"
            :width "18px"
            :height "18px"
            :viewBox "0 0 52 52"
            :enable-background "new 0 0 52 52"
            :xml:space "preserve"}
        [:g
          [:g
            [:path {:fill "#FFFFFF"
                    :d "M41.8,41H10.2c-0.8,0-1.4,0.7-1.4,1.4v0.1c0,2.5,2,4.5,4.5,4.5h25.5c2.5,0,4.5-2,4.5-4.5v-0.1\n\t\t\tC43.2,41.7,42.6,41,41.8,41z"}]]
          [:g
            [:path {:fill "#FFFFFF"
                    :d "M45.5,10.2c-2.5,0-4.5,2-4.5,4.5c0,1.4,0.6,2.6,1.6,3.4c-1.3,2.9-4.2,4.9-7.6,4.8c-4-0.2-7.2-3.4-7.4-7.4\n\t\t\tc0-0.7,0-1.3,0.1-1.9c1.7-0.7,2.9-2.2,2.9-4.2C30.5,7,28.5,5,26,5s-4.5,2-4.5,4.5c0,1.9,1.2,3.5,2.8,4.2c0.2,0.6,0.2,1.2,0.2,1.9\n\t\t\tc-0.2,4-3.4,7.2-7.4,7.4c-3.4,0.2-6.4-1.9-7.7-4.8c1-0.8,1.6-2.1,1.6-3.4c0-2.5-2-4.5-4.5-4.5S2,12.3,2,14.8s2,4.5,4.5,4.5l0,0\n\t\t\tl2.1,16c0.1,0.7,0.7,1.2,1.4,1.2H42c0.7,0,1.3-0.5,1.4-1.2l2.1-16l0,0c2.5,0,4.5-2,4.5-4.5S48,10.2,45.5,10.2z"}]]]]]
    object-name
    [:span {:class "grow"}
      [:span {:class "layout-related-new"} "New"]]])

(defn layout-related-content
  ```Retunrs the content that will appear for the Related tab.
  If there are no related objects, a placeholder message will be displayed```
  [related]
  (if (= 0 (length related))
  [:span {:class "layout-related"}
    "No related objects"]
  (map |(render-layout-related $ (get-stored-model $)) related)))

(defn render-layout-field
  [field]
  (if (= field :spacer)
    [:span]
    [:span {:class "field"}
      (string field)
      [:svg {:class "field-icon"
            :fill "#c3c3c3"
            :xmlns "http://www.w3.org/2000/svg"
            :width "800px"
            :height "800px"
            :viewBox "0 0 52 52"
            :enable-background "new 0 0 52 52"
            :xml:space "preserve"}
        [:g
          [:path {:d "M9.5,33.4l8.9,8.9c0.4,0.4,1,0.4,1.4,0L42,20c0.4-0.4,0.4-1,0-1.4l-8.8-8.8c-0.4-0.4-1-0.4-1.4,0L9.5,32.1\n\t\tC9.1,32.5,9.1,33.1,9.5,33.4z"}]
          [:path {:d "M36.1,5.7c-0.4,0.4-0.4,1,0,1.4l8.8,8.8c0.4,0.4,1,0.4,1.4,0l2.5-2.5c1.6-1.5,1.6-3.9,0-5.5l-4.7-4.7\n\t\tc-1.6-1.6-4.1-1.6-5.7,0L36.1,5.7z"}]
          [:path {:d "M2.1,48.2c-0.2,1,0.7,1.9,1.7,1.7l10.9-2.6c0.4-0.1,0.7-0.3,0.9-0.5l0.2-0.2c0.2-0.2,0.3-0.9-0.1-1.3l-9-9\n\t\tc-0.4-0.4-1.1-0.3-1.3-0.1s-0.2,0.2-0.2,0.2c-0.3,0.3-0.4,0.6-0.5,0.9L2.1,48.2z"}]]]]))

(defn render-layout-detail
  [detail reference]
  (let [label (detail :label)
        display (detail :display)
        fields (detail :fields)]
    [:div {:class "layout-detail"}
      [:div {:class "layout-detail-label"}
        [:svg {:class "icon"
               :style "width: 1.4rem; height: 1.4rem; display: grid"
               :onclick "collapse(window.event)"
               :width "800px"
               :height "800px"
               :viewBox "0 0 24 24"
               :fill "none"
               :xmlns "http://www.w3.org/2000/svg"}
          [:path {:d "M6 9L12 15L18 9"
                  :stroke "#181818"
                  :stroke-width "2"
                  :stroke-linecap "round"
                  :stroke-linejoin "round"}]]
        [:svg {:class "icon"
               :style "width: .9rem; height: .9rem; display: none"
               :onclick "expand(window.event)"
               :height "800px"
               :width "800px"
               :version "1.1"
               :xmlns "http://www.w3.org/2000/svg"
               :xmlns:xlink "http://www.w3.org/1999/xlink"
               :viewBox "0 0 185.343 185.343"
               :xml:space "preserve"}
          [:g [:g [:path {:style "fill:#181818;"
                          :d "M51.707,185.343c-2.741,0-5.493-1.044-7.593-3.149c-4.194-4.194-4.194-10.981,0-15.175\n\t\t\tl74.352-74.347L44.114,18.32c-4.194-4.194-4.194-10.987,0-15.175c4.194-4.194,10.987-4.194,15.18,0l81.934,81.934\n\t\t\tc4.194,4.194,4.194,10.987,0,15.175l-81.934,81.939C57.201,184.293,54.454,185.343,51.707,185.343z"}]]]]
        label]
      [:div {:class display}
        (map (fn [f]
              (let [field (if (= f :spacer) :spacer (get-referenced-field-name f reference))]
              (render-layout-field field)))
          fields)]]))

(defn layout
  [object content]
  (let [parsed (parse content)
        details (parsed :details)
        related (parsed :related)
        highlights (parsed :highlights)
        reference (get-stored-model (parse object))
        object-name (object-name (string object))]
    [:div {:id object :class "layout"}
      [:span {:class "object-display"} object-name]
      # details/related
      (render-tabs [{:label "Related"
                     :content (layout-related-content related)}
                    {:label "Details"
                     :content (map |(render-layout-detail $ reference) details)}])]))
