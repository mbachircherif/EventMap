// The MIT License (MIT)
//
// Copyright (c) 2016 Naoki Hiroshima
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

var MatrixBitmapOdd = [ ["b", "c", "f", "g", "u", "v", "y", "z"], ["8", "9", "d", "e", "s", "t", "w", "x"], ["2", "3", "6", "7", "k", "m", "q", "r"], ["0", "1", "4", "5", "h", "j", "n", "p"] ]

var MatrixBitmapEven = [ ["p", "r", "x", "z"], ["n", "q", "w", "y"], ["j", "m", "t", "v"], ["h", "k", "s", "u"], ["5", "7", "e", "g"], ["4", "6", "d", "f"], ["1", "3", "9", "c"], ["0", "2", "8", "b"] ]

struct MatrixCoordinates {
    var x: Int
    var y: Int
}

// Hashable Strutc of (String Prefix, Int Degree)
struct Dprefix: Hashable{
    var prefix : String
    var degree : Int
    
    var hashValue: Int {
        //return "(\(prefix),\(degree))".hashValue
        return "(\(prefix))".hashValue
    }
    
    static func == (lhs: Dprefix, rhs: Dprefix) -> Bool {
        return lhs.prefix == rhs.prefix //&& lhs.degree == rhs.degree
    }
    
}

struct Geohash {
    static func decode(hash: String) -> (latitude: (min: Double, max: Double), longitude: (min: Double, max: Double))? {
        // For example: hash = u4pruydqqvj
        
        let bits = hash.characters.map { bitmap[$0] ?? "?" }.joined(separator: "")
        guard bits.characters.count % 5 == 0 else { return nil }
        // bits = 1101000100101011011111010111100110010110101101101110001
        
        let (lat, lon) = bits.characters.enumerated().reduce(([Character](), [Character]())) {
            var result = $0
            if $1.0 % 2 == 0 {
                result.1.append($1.1)
            } else {
                result.0.append($1.1)
            }
            return result
        }
        // lat = [1,1,0,1,0,0,0,1,1,1,1,1,1,1,0,1,0,1,1,0,0,1,1,0,1,0,0]
        // lon = [1,0,0,0,0,1,1,1,0,1,1,0,0,1,1,0,1,0,0,1,1,1,0,1,1,1,0,1]
        
        func combiner(array a: (min: Double, max: Double), value: Character) -> (Double, Double) {
            let mean = (a.min + a.max) / 2
            return value == "1" ? (mean, a.max) : (a.min, mean)
        }
        
        let latRange = lat.reduce((-90.0, 90.0), combiner)
        // latRange = (57.649109959602356, 57.649111300706863)
        
        let lonRange = lon.reduce((-180.0, 180.0), combiner)
        // lonRange = (10.407439023256302, 10.407440364360809)
        
        return (latRange, lonRange)
    }
    
    static func encode(latitude: Double, longitude: Double, length: Int) -> String {
        // For example: (latitude, longitude) = (57.6491106301546, 10.4074396938086)
        
        func combiner(array a: (min: Double, max: Double, array: [String]), value: Double) -> (Double, Double, [String]) {
            let mean = (a.min + a.max) / 2
            if value < mean {
                return (a.min, mean, a.array + "0")
            } else {
                return (mean, a.max, a.array + "1")
            }
        }
        
        let lat = Array(repeating: latitude, count: length*5).reduce((-90.0, 90.0, [String]()), combiner)
        // lat = (57.64911063015461, 57.649110630154766, [1,1,0,1,0,0,0,1,1,1,1,1,1,1,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,0,...])
        
        let lon = Array(repeating: longitude, count: length*5).reduce((-180.0, 180.0, [String]()), combiner)
        // lon = (10.407439693808236, 10.407439693808556, [1,0,0,0,0,1,1,1,0,1,1,0,0,1,1,0,1,0,0,1,1,1,0,1,1,1,0,1,0,1,..])
        
        let latlon = lon.2.enumerated().flatMap { [$1, lat.2[$0]] }
        // latlon - [1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,...]
        
        let bits = latlon.enumerated().reduce([String]()) { $1.0 % 5 > 0 ? $0 << $1.1 : $0 + $1.1 }
        //  bits: [11010,00100,10101,10111,11010,11110,01100,10110,10110,11011,10001,10010,10101,...]
        
        let arr = bits.flatMap { charmap[$0] }
        // arr: [u,4,p,r,u,y,d,q,q,v,j,k,p,b,...]
        
        return String(arr.prefix(length))
    }
    
    /// NEW FUNCTION
    
    static func proximyHash(prefixGeoboxes: [String], cardinalHash: [String:String], precision: Int, step: Int, boundingLimits: [String:CLLocationCoordinate2D]) -> [String:AnyObject] {
        
        var currentPrecision : Int = precision
        let expectedPrecision : Int = precision + 3
        
        var setGeohash : [Int : [String]] = [precision : prefixGeoboxes]
        
        var newBoundingLimits : [String: (latitude: Double, longitude: Double)] = [:]
        var newBoudingLimitsIndexes : [String:MatrixCoordinates] = [:]
        var cardinalHash : [String:String] = [:]
        var setPositifGeohash : [String] = []
        
        /// NSMutableDictionary is a class
        /// Dictionnary is a struct
        /// Struct can't be pass as reference sauf avec 'inout' mais impact les performances
        /// Les classes peuvent être passé comme des références (Bug rencontré avec les Set dans NSMutableDicitionnary)
        
        var LPrefix : NSMutableDictionary = [:]
        
        repeat {
            //Don't forget to clear cardinalHash
            cardinalHash.removeAll()
            newBoundingLimits.removeAll()
            newBoudingLimitsIndexes.removeAll()
            setGeohash[currentPrecision + 1] = []
            
            // For each geoHash, define it's limit NW and SE to subdivise
            for hash in setGeohash[currentPrecision]! {
                if !isInBoudingBox(geohash: hash, limitBounds: boundingLimits){
                    
                    // We subdivise only if geohashboxes are not in the boudaries
                    let decodeGeohash = Geohash.decode(hash: hash)!
                    
                    let nwLatitudes : [Double] = [Double((boundingLimits["nw"]?.latitude)!), decodeGeohash.latitude.max]
                    let nwLongitudes : [Double] = [Double((boundingLimits["nw"]?.longitude)!), decodeGeohash.longitude.min]
                    
                    let seLatitudes : [Double] = [Double((boundingLimits["se"]?.latitude)!), decodeGeohash.latitude.min]
                    let seLongitudes : [Double] = [Double((boundingLimits["se"]?.longitude)!), decodeGeohash.longitude.max]
                    
                    newBoundingLimits["nw"] = (latitude: nwLatitudes.min(), longitude: nwLongitudes.max()) as? (latitude: Double, longitude: Double)
                    newBoundingLimits["se"] = (latitude: seLatitudes.max(), longitude: seLongitudes.min()) as? (latitude: Double, longitude: Double)
                    
                    // Traduction
                    let seGeohash = Geohash.encode(latitude: (newBoundingLimits["se"]?.latitude)! + 0.0000000001, longitude: (newBoundingLimits["se"]?.longitude)! - 0.0000000001, length: currentPrecision+1)
                    let nwGeohash = Geohash.encode(latitude: (newBoundingLimits["nw"]?.latitude)! - 0.0000000001, longitude: (newBoundingLimits["nw"]?.longitude)! + 0.0000000001, length: currentPrecision+1)
                    
                    //print (nwGeohash, seGeohash, currentPrecision)
                    // Get new Indexes
                    if seGeohash == nwGeohash {
                        
                        let cardinalLetters : [String: String] = ["nw": String(describing: Array(nwGeohash)[currentPrecision])]
                        newBoudingLimitsIndexes = self.getIndex2DArray(data: cardinalLetters, matrix: parityMatrix(precision: currentPrecision+1))
                        newBoudingLimitsIndexes["se"] = newBoudingLimitsIndexes["nw"]
                        
                    } else {
                        let cardinalLetters : [String: String] = ["nw": String(describing: Array(nwGeohash)[currentPrecision]),
                                                                  "se": String(describing: Array(seGeohash)[currentPrecision])]
                        newBoudingLimitsIndexes = self.getIndex2DArray(data: cardinalLetters, matrix: parityMatrix(precision: currentPrecision+1))
                    }
                    
                    for newHash in self.getHashesByLimitMatrix(prefix: hash, matrix: parityMatrix(precision: currentPrecision+1), xLower: newBoudingLimitsIndexes["nw"]!.x, xHigher: newBoudingLimitsIndexes["se"]!.x, yLower: newBoudingLimitsIndexes["nw"]!.y, yHigher: newBoudingLimitsIndexes["se"]!.y){
                        setGeohash[currentPrecision + 1]?.append(newHash)
                        //https://stackoverflow.com/questions/24250938/swift-pass-array-by-reference
                        
                    }
                } else {
                    //setGeohash[currentPrecision + 1]?.append(hash)
                    setPositifGeohash.append(hash)
                    LPrefix = NewsubstringPrefix(string: hash, prefixNbrChar: 3, tree: LPrefix)
                   
                    }
            }
            
            currentPrecision += 1
            
        } while currentPrecision <= expectedPrecision
        
        // Get prefixes of every positif hashes
        
        //print ("LPrefix - Geohash.s ->", LPrefix)
        return ["LPrefix" : LPrefix as AnyObject, "setPositifGeohash":setPositifGeohash as AnyObject]//setPositifGeohash
    }
    
    private static func getIndex2DArray(data: [String:String], matrix: [[String]]) -> [String:MatrixCoordinates]{
        var index : [String:MatrixCoordinates] = [:]
        for i in 0...matrix.count - 1{
            for j in 0...matrix[i].count - 1 {
                for (key, value) in data { // "ne" : MatrixCoordinates
                    if value == matrix[i][j] {
                        index[key] = MatrixCoordinates(x: i, y: j)
                    }
                }
            }
        }
        
        return index
    }
    
    // Geohash Matrix Limits
    private static func getHashesByLimitMatrix(prefix: String, matrix: [[String]], xLower: Int, xHigher: Int, yLower: Int, yHigher: Int) -> [String]{
        var geohashSet : [String] = []
        for x in xLower...xHigher{
            for y in yLower...yHigher{
                geohashSet.append(prefix+matrix[x][y])
            }
        }
        return geohashSet
    }
    
    private static func isInBoudingBox(geohash:String, limitBounds:[String:CLLocationCoordinate2D]) /*[String:(latitude: Double, longitude: Double)]*/ -> Bool {
        let decodeGeohash = self.decode(hash: geohash)!
        let boundsMarginLatitude : Double = (decodeGeohash.latitude.max - decodeGeohash.latitude.min) * (1/4) // Plus on diminue et plus on est précis 0.04
        let boundsMarginLongitude : Double = (decodeGeohash.longitude.max - decodeGeohash.longitude.min) * (1/4) // Plus on diminue plus on est précis, de 0.09
        var isInTheBox = true
        
        // CHECK North And West
        if Double((limitBounds["nw"]?.latitude)!) + boundsMarginLatitude < decodeGeohash.latitude.max || Double((limitBounds["nw"]?.longitude)!) - boundsMarginLongitude  > decodeGeohash.longitude.min{
            isInTheBox = false
        }
        
        // CHECK South AND East
        if Double((limitBounds["se"]?.latitude)!) - boundsMarginLatitude > decodeGeohash.latitude.min || Double((limitBounds["se"]?.longitude)!) + boundsMarginLongitude < decodeGeohash.longitude.max{
            isInTheBox = false
        }
        
        return isInTheBox
    }
    
    private static func getLetterWithPrecision(precision: Int, str: String) -> String {
        let index = str.characters.index(str.startIndex, offsetBy: precision - 1)
        return String(describing: str[index])
    }
    
    private static func parityMatrix(precision:Int) -> [[String]]{
        if precision % 2 == 0 {
            return MatrixBitmapEven
        } else { return MatrixBitmapOdd }
    }
    
    // https://stackoverflow.com/questions/24250938/swift-pass-array-by-reference
    // Utilisation NSDictionnary car class (les classes sont passé par référence) au lieu de Dictionnary qui est une structure qui n'est pas passé en tant que reference
    private static func NewsubstringPrefix(string : String, prefixNbrChar : Int, tree: NSMutableDictionary) -> NSMutableDictionary{
        
        let prefix_nbr_car = prefixNbrChar
        let setPrefix = tree
        var multiple = 1
        var endIndex : String.Index
        var startIndex = string.index(string.startIndex, offsetBy: 0)
        
        if string.count < prefixNbrChar {
            endIndex = string.index(string.startIndex, offsetBy: string.count)
        } else {endIndex = string.index(string.startIndex, offsetBy: prefixNbrChar)}
        
        let keyPrefix : String = string.substring(with: Range(startIndex..<endIndex))
        
        if setPrefix.value(forKey: keyPrefix) == nil {
            let dic : NSMutableDictionary = [:]
            setPrefix[keyPrefix] = dic
        }
        
        var treePrefix : String = keyPrefix
        
        while prefix_nbr_car * multiple < string.count {
            
            startIndex = string.index(string.startIndex, offsetBy: prefix_nbr_car * multiple)
            
            if prefix_nbr_car * (multiple + 1) <= string.count {
                endIndex = string.index(string.startIndex, offsetBy: prefix_nbr_car * (multiple + 1))
                let pref = string.substring(with: Range(startIndex..<endIndex))
                multiple += 1
                
                if setPrefix.value(forKeyPath: treePrefix+"."+pref) == nil {
                    let dicPath = setPrefix.value(forKeyPath: treePrefix) as! NSMutableDictionary
                    let dict : NSMutableDictionary = [:]
                    dicPath.setObject(dict, forKey: pref as NSCopying)
                }
                
                treePrefix += "."+pref
                
            } else {
                endIndex = string.index(string.startIndex, offsetBy: string.count)
                let pref = string.substring(with: Range(startIndex..<endIndex))
                multiple += 1
                
                if setPrefix.value(forKeyPath: treePrefix+"."+pref) == nil {
                    let dicPath = setPrefix.value(forKeyPath: treePrefix) as! NSMutableDictionary
                    let dict : NSMutableDictionary = [:]
                    dicPath.setObject(dict, forKey: pref as NSCopying)
                }
                
                treePrefix += "."+pref
            }
            
        }

        return setPrefix
    }
    
    // MARK: Private
    
    private static let bitmap = "0123456789bcdefghjkmnpqrstuvwxyz".characters.enumerated()
        .map {
            ($1, String(integer: $0, radix: 2, padding: 5))
        }
        .reduce([Character: String]()) {
            var dict = $0
            dict[$1.0] = $1.1
            return dict
    }
    
    private static let charmap = bitmap
        .reduce([String: Character]()) {
            var dict = $0
            dict[$1.1] = $1.0
            return dict
    }
}

extension Geohash {
    enum Precision: Int {
        case twentyFiveHundredKilometers = 1    // ±2500 km
        case sixHundredThirtyKilometers         // ±630 km
        case seventyEightKilometers             // ±78 km
        case twentyKilometers                   // ±20 km
        case twentyFourHundredMeters            // ±2.4 km
        case sixHundredTenMeters                // ±0.61 km
        case seventySixMeters                   // ±0.076 km
        case nineteenMeters                     // ±0.019 km
        case twoHundredFourtyCentimeters        // ±0.0024 km
        case sixtyCentimeters                   // ±0.00060 km
        case seventyFourMillimeters             // ±0.000074 km
    }
    
    static func encode(latitude: Double, longitude: Double, precision: Precision) -> String {
        return encode(latitude: latitude, longitude: longitude, length: precision.rawValue)
    }
}

private extension String {
    init(integer n: Int, radix: Int, padding: Int) {
        let s = String(n, radix: radix)
        let pad = (padding - s.characters.count % padding) % padding
        self = Array(repeating: "0", count: pad).joined(separator: "") + s
    }
}

private func + (left: [String], right: String) -> [String] {
    var arr = left
    arr.append(right)
    return arr
}

private func << (left: [String], right: String) -> [String] {
    var arr = left
    var s = arr.popLast()!
    s += right
    arr.append(s)
    return arr
}

#if os(OSX) || os(iOS)
    
    // MARK: - CLLocationCoordinate2D
    
    import CoreLocation
    
    extension CLLocationCoordinate2D {
        init(geohash: String) {
            if let (lat, lon) = Geohash.decode(hash: geohash) {
                self = CLLocationCoordinate2DMake((lat.min + lat.max) / 2, (lon.min + lon.max) / 2)
            } else {
                self = kCLLocationCoordinate2DInvalid
            }
        }
        
        func geohash(length: Int) -> String {
            return Geohash.encode(latitude: latitude, longitude: longitude, length: length)
        }
        
        func geohash(precision: Geohash.Precision) -> String {
            return geohash(length: precision.rawValue)
        }
    }
    
#endif
