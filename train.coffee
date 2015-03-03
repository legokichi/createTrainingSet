fs = require('fs')
svm = require('node-svm')
labelAndFile = {}
main = ->
  console.log new Date()
  labelAndFile =
    0: "寝ている.csv"
    1: "立っている.csv"
    2: "歩いている.csv"
    3: "走っている.csv"
    4: "座っている.csv"
  console.log labelAndFile
  _main ->
    console.log "end."

    labelAndFile =
      0: "寝転ぶ.csv"
      1: "座る.csv"
      2: "振り向き右.csv"
      3: "正面を向く.csv"
      4: "立つ.csv"
      5: "起きる.csv"
      6: "動かず.csv"
    console.log labelAndFile
    _main ->
      console.log "end."

_main = (cb)->
  [trainingSet, predictionSet] = (Object.keys(labelAndFile).map (label)->
    filepath= labelAndFile[label]
    csv = readCSV(filepath, {encoding: "utf-8"})
    csv = csv.map (a)-> a.map (b)-> Number(b)
    arr = csv.map (row)-> [row, Number(label)]
    if label is "6" then arr = shuffule(arr).slice(0, 300)
    sep = arr.length/2|0
    _a = arr.slice(0, sep)
    _b = arr.slice(sep)
    [_a, _b]
  ).reduce (([a, b], [c, d])-> [a.concat(c),b.concat(d)]),[[], []]

  clf = new svm.CSVC()


  console.time("train")
  clf.train(trainingSet).done ->
    console.timeEnd("train")
    results = Object.keys(labelAndFile).reduce(((o, label)-> o[label] = Object.keys(labelAndFile).map(-> 0); o), {})

    predictionSet.forEach ([vect, label])->
      prediction = clf.predictSync(vect)
      results[label][prediction]++
    console.log results
    cb()

shuffule = (arr)->
  _arr = []
  while arr.length > 0
    index = arr.length*Math.random()
    _arr.push arr.splice(index, 1)[0]
  _arr

readCSV = (path)->
  fs.readFileSync(path, {encoding: "utf-8"})
  .split("\n")
  .filter (a)-> a.length > 0
  .map (a)-> a.split(",")
  .map (a)-> a.map (b)-> b.trim()

main()
