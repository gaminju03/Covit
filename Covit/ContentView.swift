//
//  ContentView.swift
//  Covit
//
//  Created by Juan on 15/04/20.
//  Copyright © 2020 usuario. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home : View {
    
    @ObservedObject var data =  getData()
    var body : some View {
        
        VStack{
            if self.data.countries.count != 0 && self.data.data != nil {
               
                VStack{
                    HStack(alignment: .top){
                        VStack(alignment: .leading, spacing: 15){
                           // Text("hola")
                            Text(getDate(time: self.data.data.updated))
                          
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            
                            Text("Casos de Covid-19")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            
                          //  Text("361,635")
                            Text(getDate(time: self.data.data.cases))
                            .fontWeight(.bold)
                                .font(.title)
                            .foregroundColor(.white)
                        }
                        Spacer()
                        
                        
                        Button(action: {
                            self.data.data = nil
                            self.data.countries.removeAll()
                            self.data.updateData()
                        }){
                            Image(systemName: "arrow.clockwise")
                                .font(.title)
                                .foregroundColor(.white)
                            
                        }
                        
                        
                    }
                    .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top)! + 18)
                    .padding()
                    .padding(.bottom, 80)
                    .background(Color.blue)
                    
                    HStack(spacing: 15){
                        
                    VStack(alignment: .leading, spacing: 15){
                             Text("Muertes")
                                 
                                .foregroundColor(Color.black.opacity(0.5))
                            
                            //Text inrmacion de json muertes
                             Text(getValue(data: self.data.data.deaths))
                                .font(.title)
                                 .fontWeight(.bold)
                                .foregroundColor(.red)
                       
                        }
                        
                        .padding(.vertical, 30)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                      
                        
                        VStack(alignment: .leading, spacing: 15){
                                Text("Recuperados")
                                    .foregroundColor(Color.black.opacity(0.5))
                                           
                               // Text("3655")
                          
                                 Text(getValue(data: self.data.data.recovered))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                      
                                       }
                                       .padding(.vertical, 30)
                                       .background(Color.white)
                                       .cornerRadius(12)
                        
                            .padding(.top, 15)
                        
                                     .offset(y : -60)
                                       .padding(.bottom, -60)
                                       .zIndex(25)
                        
                        VStack(alignment: .center, spacing: 15){
                                Text("Casos Activos")
                                    .foregroundColor(Color.black.opacity(0.5))
                            
                            Text(getValue(data: self.data.data.active))
                                    .font(.title)
                                     .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                                      
                                       }
                                       .padding(.vertical, 30)
                                       .background(Color.white)
                                       .cornerRadius(12)
                        
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing:15){
                            ForEach(self.data.countries,id: \.self){i in
                                cellView(data: i)
                                
                            }
                        }
                    .padding()
                    }
                    
                }
               
            }
                
            else{
                GeometryReader{_ in
                    VStack{
                        Indicator()
                    }
                    
                }
            }
            
        }.edgesIgnoringSafeArea(.top)
        .background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all))
    }
}

func getDate(time: Double )->String{
    let date = Double(time / 1000 )
    let format = DateFormatter()
    format.dateFormat = " dd - MMM - YYYY"
    return format.string(from: Date(timeIntervalSince1970: TimeInterval(exactly: date)!))
    
}

func getValue(data : Double)->String{
    let format = NumberFormatter()
    format.numberStyle = .decimal
    
    return format.string(for: data)!
}

struct cellView : View {
    
    var data : Details
    var body: some View{
        VStack(alignment: .leading, spacing: 15){
            Text(data.country)
                .fontWeight(.bold)
            HStack(spacing:15){
                  VStack(alignment: .leading, spacing: 12){
                    Text("Casos Activos")
                        .font(.title)
                    
                    Text(getValue(data: data.cases))
                    .font(.title)
                }
                
                VStack(alignment: .leading, spacing: 12){
                   
                    VStack(alignment: .leading, spacing: 10){
                        Text("Muertes")
                        Text(getValue(data: data.deaths))
                            .foregroundColor(.red)
                
                        
                    }
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10){
                        Text("Recuperados")
                        Text(getValue(data: data.recovered))
                        .foregroundColor(.green)
                                          
                    }
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10){
                        Text("Critico")
                        Text(getValue(data: data.critical))
                        .foregroundColor(.yellow)
                                          
                    }
                
                }
                
            }
        }
    .padding()
    .frame(width: UIScreen.main.bounds.width - 30)
    .background(Color.white)
    .cornerRadius(20)
    }
    
}


struct Case : Decodable {
    var cases : Double
    var deaths : Double
    var updated : Double
    var recovered : Double
    var active : Double
    
}

struct Details : Decodable,Hashable {
    var country : String
    var cases : Double
    var deaths : Double
    var recovered : Double
    var critical : Double
    
}

class getData : ObservableObject {
    @Published var data : Case!
    @Published var countries = [Details]()
    
    init() {
        updateData()
    }
    func updateData() {
        
        let url = "https://corona.lmao.ninja/all"
        let url1 = "https://corona.lmao.ninja/countries/"
        
        let session = URLSession(configuration: .default)
        let session1 = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) {(data, _, err) in
            
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            let json = try! JSONDecoder().decode(Case.self, from: data!)
            
            DispatchQueue.main.async {
                self.data = json
            }
        }.resume()
        
       for i in country{
            session1.dataTask(with: URL(string: url1+i)!) {(data, _, err) in
                           
                           if err != nil {
                               print((err?.localizedDescription)!)
                               return
                           }
                          let json = try! JSONDecoder().decode(Details.self, from: data!)
                           DispatchQueue.main.async {
                            self.countries.append(json)
                           }
                       }.resume()
        }
     
    }
}



var country =  ["mexico","italy","spain","australia","india","china"]


struct Indicator : UIViewRepresentable {
    func  makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
        
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicator>) {
        
    }
    
    }
    
