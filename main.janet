(import spork/htmlgen)

(def styles (slurp "./default-style.css"))
(def script (slurp "./script.js"))

(var purpose "store")

(defn- capture-node
  "Capture a node in the grammar."
  [name & params]
  (if (= purpose "store")
    (if (= name "model")
      ~(,(symbol name) ,;params "store"))
    ~(,(symbol name) ,;params)))

(def- symchars
  "peg for valid symbol characters."
  '(+ (range "09" "AZ" "az" "\x80\xFF") (set "!$%&*+-./:<?=>@^_")))

(defn- capp [& content]
  (unless (empty? content)
    ~[:p ,(array/slice content)]))

(def- markup-grammar
  "PEN grammar -> document AST parser."
  ~{# basic character classes
    :wsnl (set " \t\r\v\f\n")
    :ws (set " \t\r\v\f")

    # A span of markup that is not line delimited (most markup)
    :char (+ (* "\\" 1) (if-not (set "@}") 1))
    :leaf (/ '(some :char) ,(partial string/replace "\\" ""))
    :root (some (+ :node :leaf))

    # A span or markup that is line delimited (headers, etc). @ expressions
    # can still cross line boundaries.
    :char-line (+ (* "\\" 1) (if-not (set "@}\n\r") 1))
    :leaf-line (/ '(* (some :char-line) (? "\r") (? "\n")) ,(partial string/replace "\\" ""))
    :root-line (some (+ (* :node (? '"\n")) :leaf-line))

    # An @ expression (a node)
    :node {:bracket-params (* "[" '(any (if-not "]" 1)) "]")
           :string-param (* "\"" '(any (if-not "\"" 1)) "\"")
           :longstring-param (* "`" '(any (if-not "`" 1)) "`")
           :curly-params (* "{" (/ (any :root) ,array) "}")
           :params (any (* (any :wsnl)
                           (+ :bracket-params :curly-params :string-param :longstring-param)))
           :name '(if-not (range "09") (some ,symchars))
           :main (/ (* "@" :name :params) ,capture-node)}

    # Pretty errors
    :err (error (/ (* '1 (position))
                   ,(fn [x p] (string "unmatched character "
                                      (describe x)
                                      " at byte " p))))

    # Main rule: Front matter -> Top level nodes and markup
    :main (* (any (+ '(some :wsnl)
                      (* :node (any :wsnl))
                      (/ :root-line ,capp)
                      "}"))
             (+ -1 :err))})

(def- pen-peg
  "A peg that converts pen to html."
  (peg/compile markup-grammar))

(defn default-template [contents stylesheet-name]
  [:html {:lang "en"}
   [:head
    [:title (get-in (filter array? (get contents 0)) [0 0])]
    [:meta {:charset "utf-8"}]
    [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
    (if stylesheet-name
      [:link {:href (string "./" stylesheet-name) :rel "stylesheet"}]
      [:style (htmlgen/raw styles)])
    [:script (htmlgen/raw script)]]
   [:body [:main {:class "content"} contents]]])

(defn template-jordanschatz.com [contents stylesheet-name]
  [:html {:lang "en"}
   [:head
      [:title (get-in (filter array? (get contents 0)) [0 0])]
    [:meta {:charset "utf-8"}]
    [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
    (if stylesheet-name
      [:link {:href (string "/" stylesheet-name) :rel "stylesheet"}]
      [:style (htmlgen/raw styles)])]
   [:body
      [:nav
         [:a {:href "/"} [:img {:src "/img/logo-small.png" :class "nav-logo" :width "25"}]]
       [:ul {:class "nav-items"}
        [:li {:class "nav-item"}
         [:a {:href "/projects.html"}
          [:img {:src "/img/pen.svg" :class "nav-item-icon"}]
          "Projects"]]]
       [:a {:class "about" :href "/about.html"} "About"]]
    [:main {:class "content"} contents]
    [:footer
       [:a {:href "/subscribe.html" :class "footer-link"} "Subscribe"]
     [:a {:href "/comment.html" :class "footer-link"} "Comment"]]]])

(defn help []
  (print `

Convert a file in pen markup to HTML.

pen filename.pen
pen filename.pen stylesheet.css

To generate a standalone HTML file with pen's default CSS embeded
within it, use the first form. To generate HTML linking to the
provided css stylesheet name, use the second.

`))

#
# Needed tags
#
# @o for objects always as the fully qualified name
# @f for fields always as the fully qualified name
# @layout [:fully-qualified-object name ]{layout-object}
# @model`` a model object
# :Text-Area-(Rich) should probably be :Text-Area-Rich
#

(def env (require "./env"))

(defn main
  "filename.pen -> filename.html"
  [& args]
  (if (or (= (get args 1) "help")
          (= (get args 1) "-help")
          (= (get args 1) "--help")
          (nil? (get args 1)))
    (help)
    (let [filename (get args 1)
          base (string/trim
                (first
                 (array/slice
                  (string/split "." filename) -3)) "\\/")
          contents (slurp filename)
          _ (set purpose "store")
          thunk-store (compile (peg/match pen-peg (slurp filename)) env)
          _ (thunk-store)
          _ (set purpose "parse")
          thunk (compile (peg/match pen-peg (slurp filename)) env)
          parsed (thunk)
          template (if (= (get args 3) "jordanschatz.com") template-jordanschatz.com default-template)
          html (htmlgen/html (template parsed (get args 2)) @"<!DOCTYPE html>")]
      (spit (string "./" base ".html") html))))
