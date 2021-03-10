#!/usr/bin/env clojure

(require '[babashka.process :as process]
         '[babashka.curl :as curl]
         '[clojure.edn :as edn]
         '[clojure.java.io :as io]
         '[clojure.string :as str])

(def config
  (edn/read-string (slurp "config.edn")))

(defn get-docker-tag
  [config]
  (str (:container-registry config)
       "/gcloud-datomic-backup:"
       (:datomic-version config)))

(defn download-file!
  [url dest-file]
  (io/copy
   (:body (curl/get url
                    {:as :stream}))
   (io/file dest-file)))

(defn extract-file-name
  [url]
  (str/replace url
               #".*/"
               ""))

(defn download-extra-libs!
  [config]
  (let [extra-libs-dir (io/file "extra-libs")]
    (.mkdir extra-libs-dir)
    (doseq [url (:extra-libs config)]
      (download-file! url
                      (io/file extra-libs-dir
                               (extract-file-name url))))))

(defn build!
  [config]
  @(process/process
    ["docker" "build"
     "--build-arg" (str "DATOMIC_CREDENTIALS="
                        (:datomic-credentials config))
     "--build-arg" (str "DATOMIC_VERSION="
                        (:datomic-version config))
     "-t" (get-docker-tag config)
     "."]
    {:out :inherit
     :err :inherit}))

(defn push!
  [config]
  @(process/process
    ["docker" "push"
     (get-docker-tag config)]
    {:out :inherit
     :err :inherit}))

(defn check-exit-code
  [process-result]
  (if (= (:exit process-result)
         0)
    process-result
    (throw (ex-info "non-zero exit-code"
                    {:process-result process-result}))))

(download-extra-libs! config)
(check-exit-code (build! config))
(check-exit-code (push! config))

(println "Docker tag:\n"
         (get-docker-tag config))
