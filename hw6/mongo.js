// task 1
// use hw6


// use `mongoimport`
// mongoimport --uri "mongodb+srv://cdxvy30:1MyKwJEzKewn4Wta@cluster0.fdydn0q.mongodb.net" --type csv -d hw6 -c students --headerline --file ~/Downloads/hw6_files/DBMS_student_list.csv

// task 2
db.students.find(
  { "信箱": 
    { $in: 
      [ 
        "r11521603@ntu.edu.tw", "r11521613@ntu.edu.tw", "r11521616@ntu.edu.tw", "r10724039@ntu.edu.tw", "r11944022@ntu.edu.tw" 
      ] 
    } 
  }
)

// task 3
db.students.aggregate([
  {
    $group: {
      _id: { 系所: "$系所", 年級: "$年級" },
      count: { $sum: 1 }
    }
  }
])

// task 4
db.students.updateMany({}, { $set: { join_date: "2023-03-01" } })

// task 5 
// db.collection.insertMany
db.students.insertMany([
  {
    "身份": "旁聽生",
    "系所": "電機所",
    "年級": "2",
    "學號": "R10123456",
    "姓名": "小紅",
    "join_date": "2023-06-02"
  },
  {
    "身份": "學生",
    "系所": "物理所",
    "年級": "3",
    "學號": "B09987653",
    "姓名": "小黃",
    "join_date": "2023-06-02"
  },
  {
    "身份": "觀察者",
    "系所": "電信所",
    "年級": "1",
    "學號": "R11123001",
    "姓名": "小綠",
    "join_date": "2023-06-02"
  }
])

// find
db.students.find({
  "學號":
    {
      $in:
        [
          "R11521603", "R10123456", "B09987653", "R11123001"
        ]
    }
})

// (extra) db.collection.deleteMany
// db.students.deleteMany(
//   { "_id": 
//     { $in: 
//       [ 
//         ObjectId("64893598ea644d5cd4074644"), ObjectId("64893598ea644d5cd4074645"), ObjectId("64893598ea644d5cd4074646")
//       ] 
//     } 
//   }
// )

// (optional) use `mongoimport`
// mongoimport --uri "mongodb+srv://cdxvy30:1MyKwJEzKewn4Wta@cluster0.fdydn0q.mongodb.net" --type csv --headerline --file /Downloads/hw6_files/new_student_list.csv --collection students --db hw6

// task 6
db.students.insertOne({
  _id: "tally",
  date: "2023-03-31",
  departments: []
})

db.students.aggregate([
  { $match: { join_date: { $lte: "2023-03-31" } } },
  { $group: { _id: { 系所: "$系所", 年級: "$年級" }, count: { $sum: 1 } } },
  { $project: { _id: 0, 系所: "$_id.系所", 年級: "$_id.年級", count: 1 } },
  { $group: { _id: "$系所", grades: { $push: { 年級: "$年級", count: "$count" } } } },
  { $project: { _id: 0, 系所: "$_id", 年級: 1 } },
  { $group: { _id: "tally", date: { $first: "$date" }, 系所: { $push: "$$ROOT" } } },
  { $project: { _id: 0, date: 1, 系所: 1 } }
])
