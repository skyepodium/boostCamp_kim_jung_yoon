import Foundation

//사용자의 홈 경로를 문자열로 선언 ex: "/users/yagom"
let originPath: String = NSHomeDirectory()

//1)Data 데이터 타입으로 선언된 data에 students.json파일의 내용을 넣는다. 2) 경로설정에 보간법사용
let data: Data? = FileManager.default.contents (atPath : "\(originPath)/students.json")

//학생별 평균점수를 저장하는 딕셔너리
var studentScore: [String: Double] = [:]

//학생별 과목점수의 담기 위한 함수
var sum: Double = 0

//모든 학생의 평균점수를 담기 위한 함수
var totalSum: Double = 0

//모든 학생수를 담기 위한 변수
var totalNum: Double = 0

//학생들의 이름을 알파벳 순서로 담기 위한 변수
var names: [String] = []

//알파벳 순서로 들어간 각 학생의 평균점수를 담기 위한 변수
var scores: [Double] = []

//수료학생들을 담기 위한 변수
var completedStudents: [String] = []

//결과 파일의 이름
let resultFilename: String = "result.txt"

//결과로 출력할 내용
var resultText: String = ""

//string형태의 경로를 URL타입으로 변경
let url = URL(fileURLWithPath: originPath)

//결과파일이 쓰여질 경로 조합
let resultPath = url.appendingPathComponent(resultFilename)



func serializeJson(){
    
    //json파일 직렬화
    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]]{
        
        //한 학생마다 돌아가면 정보를 확인할 것이다.
        for student in json!{
            //한 학생의 과목들을 딕셔너리로 선언
            let subjects: Dictionary = (student["grade"] as? [String: Double])!
            
            //반복문을 통해 한 학생의 모든 과목의 점수를 더한다.
            for (_, value) in subjects{
                sum = sum + value
            }
            
            //한 학생의 이름을 key, 점수(과목총합/과목수)를 value로 studentScore 딕셔너리에 넣는다.
            studentScore[student["name"] as! String] = sum/Double((subjects.count))
            sum = 0
        }
    }
}


//studentScore에 순서없이 들어간 학생들의 정보를 학생이름의 알파벳순으로 정렬한다.
//정렬된 이름 순으로 names 배열에 넣고 names배열에 넣은 순으로 학생의 점수를 scores배열에 넣는다.
func sortAlpahbetically(){
    
    for key in studentScore.keys.sorted() {
        names.append(key)
        let value = studentScore[key]!
        scores.append(value)
        totalSum = totalSum + value
        
        //점수가 70점이 넘는 학생은 수료자이기 때문에 completedStudents배열에 넣는다.
        if value > 70 {
            completedStudents.append(key)
        }
        
    }
    
}

//전체 평균점수(소수점 셋째 자리에서 반올림)를 반환하는 함수
func calAverage(totalSum: Double, totalNum: Double) -> Double{
    
    let numbOfPlaces: Double = 2.0
    let multiplier = pow(10.0, numbOfPlaces)
    let average = totalSum/totalNum
    
    let roundedAverage = round(average * multiplier) / multiplier
    return roundedAverage
    
}


//점수(Double)를 통해 학생들의 등급을 설정하는 함수 문자열 형태로 등급(String)을 반환한다.
func checkGrade(score: Double) -> String{
    //결과 저장을 위한 문자열
    var result: String
    
    if(score >= 90){
        result = "A"
    }else if(score >= 80){
        result = "B"
    }else if(score >= 70){
        result = "C"
    }else if(score >= 60){
        result = "D"
    }else{
        result = "F"
    }
    return result
}


//점수를 통해 계산된 내용을 문자열로 작성하여 resultText에 추가한다.
func writeResultstring(){
    
    resultText.append("성적 결과표\n")
    //calVerage함수를 호출하여 전체 평균을 얻는다.
    resultText.append("\n전체 평균 : \(calAverage(totalSum: totalSum, totalNum: Double(studentScore.count)))\n")
    resultText.append("\n개인별 학점\n")
    
    //학생별 이름과 성적을 반복문과 보간법 그리고 특수문자 \t를 사용해서 한줄씩 표시한다.
    for i in stride(from: 0, to: names.count, by: 1) {
        resultText.append("\(names[i])\t\t: \(checkGrade(score: scores[i]))\n")
    }
    
    resultText.append("\n수료생\n")
    //수료자의 학생들을 콤마+빈칸으로 분리해서 한줄에 표시한다.
    resultText.append(completedStudents.joined(separator: ", "))
    
}


//resultText의 내용을 경로(/Users/yagom/result.txt)에 생성한다.
func createResultfile(){
    
    do {
        try resultText.write(to: resultPath, atomically: false, encoding: String.Encoding.utf8)
        print("결과파일이 작성되었습니다.")
    }
    catch {
        print("결과파일이 작성되지않습니다.")
    }
    
}

serializeJson()
sortAlpahbetically()
writeResultstring()
createResultfile()

