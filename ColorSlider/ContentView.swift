//
//  ContentView.swift
//  ColorSlider
//
//  Created by eHeuristic on 17/12/19.
//  Copyright © 2019 eHeuristic. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var isOpen: Bool = false
    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    self.isOpen = true
                }, label: {
                    Text("Tap me")
                        .foregroundColor(obj_saved_color.set_color)
                })
            }
            if isOpen {
                ZStack {
                    Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.vertical)
                    slider_popup(pop_up_isOpen: $isOpen)
                }
            }
        }
    }
}

struct SwiftUISlider: UIViewRepresentable {
  final class Coordinator: NSObject {
    var value: Binding<Double>
    
    init(value: Binding<Double>) {
      self.value = value
    }

    @objc func valueChanged(_ sender: UISlider) {
        print(Double(sender.value))
        self.value.wrappedValue = Double(sender.value)
    }
  }

  @Binding var value: Double
  var tag: Int

  func makeUIView(context: Context) -> UISlider {
    let slider = UISlider(frame: .zero)
    slider.thumbTintColor = UIColor.white
    slider.minimumTrackTintColor = UIColor.clear
    slider.maximumTrackTintColor = UIColor.clear
    slider.maximumValue = 255
    slider.tag = tag
    slider.value = Float(value)

    slider.addTarget(
      context.coordinator,
      action: #selector(Coordinator.valueChanged(_:)),
      for: .valueChanged
    )
    return slider
  }

  func updateUIView(_ uiView: UISlider, context: Context) {
    uiView.value = Float(self.value)
  }

  func makeCoordinator() -> SwiftUISlider.Coordinator {
     Coordinator(value: $value)
  }
}

struct slider_popup: View {
    @ObservedObject var settings = Color_value()
    @Binding var pop_up_isOpen: Bool
    var body: some View {
        GeometryReader { geometry in
        VStack(alignment: .leading) {
                Spacer()
                circle_view_section(value_red: self.$settings.red_value,value_green: self.$settings.green_value, value_blue: self.$settings.blue_value)
                Spacer()
                set_slider(value: self.$settings.red_value, text_str: self.settings.red_value, tag: 1, width: geometry.size.width)
                set_slider(value: self.$settings.green_value, text_str: self.settings.green_value, tag: 2, width: geometry.size.width)
                set_slider(value: self.$settings.blue_value, text_str: self.settings.blue_value, tag: 3, width: geometry.size.width)
                Spacer()
                close_popup_section(value_red: self.$settings.red_value, value_green: self.$settings.green_value, value_blue: self.$settings.blue_value, pop_up_isOpen: self.$pop_up_isOpen)
                Spacer()
            }
            .background(Color.white)
            .frame(minWidth: 0, maxWidth: geometry.size.width * 0.85, minHeight: 0, maxHeight: geometry.size.height/2, alignment: .center)
        }
    }
}

struct close_popup_section: View {
  @Binding var value_red: Double
  @Binding var value_green: Double
  @Binding var value_blue: Double
  @Binding var pop_up_isOpen: Bool
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                self.pop_up_isOpen = false
            }, label: {
                Text("Cancel")
            })
            Spacer()
            Button(action: {
                obj_saved_color.set_color = Color.init(UIColor(displayP3Red: CGFloat(self.value_red/255), green: CGFloat(self.value_green/255), blue: CGFloat(self.value_blue/255), alpha: CGFloat(1.0)))
                self.pop_up_isOpen = false
            }, label: {
                Text("Save")
            })
            Spacer()
        }
    }
}

func return_color(tag: Int)-> Color {
    if tag == 1 {
    return .init(UIColor(displayP3Red: CGFloat(255/255), green: CGFloat(0/255), blue: CGFloat(0/255), alpha: 1.0))
    }
    else if tag == 2 {
      return .init(UIColor(displayP3Red: CGFloat(0/255), green: CGFloat(255/255), blue: CGFloat(0/255), alpha: 1.0))
    }
    else {
     return .init(UIColor(displayP3Red: CGFloat(0/255), green: CGFloat(0/255), blue: CGFloat(255/255), alpha: 1.0))
    }
}

struct set_slider: View {
    @Binding var value: Double
    var text_str: Double
    var tag: Int
    var width: CGFloat
    var body: some View {
        HStack {
            Spacer()
            SwiftUISlider(value: $value, tag: tag)
                .frame(width: width * 0.65, height: 25)
                .background(LinearGradient(gradient: Gradient(colors: [.init(UIColor(displayP3Red: CGFloat(0/255), green: CGFloat(0/255), blue: CGFloat(0/255), alpha: CGFloat(1.0))), return_color(tag: tag)]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
                .padding(.top, 20)
            set_slider_text_value(text_str: text_str)
            Spacer()
        }
    }
}

func set_slider_text_value(text_str: Double)->some View {
    return Text(String(format: "%.1f", text_str))
        .foregroundColor(Color.init(UIColor.label))
}

func set_text(str_text: String)-> some View {
    return Text(str_text)
        .foregroundColor(Color.init(UIColor.label))
}

func draw_circle(red: Double = 0, green: Double = 0, blue: Double = 0)-> some View {
    return Circle()
        .fill(Color.init(UIColor(displayP3Red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)))
        .overlay(Circle()
            .stroke(Color.black, lineWidth: 1))
        .frame(width: 40, height: 40)
}

struct circle_view_section: View {
    @Binding var value_red: Double
    @Binding var value_green: Double
    @Binding var value_blue: Double
    var body: some View {
        VStack {
            HStack {
                draw_circle(red: value_red)
                set_text(str_text: "+")
                draw_circle(green: value_green)
                set_text(str_text: "+")
                draw_circle(blue: value_blue)
                set_text(str_text: "=")
                draw_circle(red: value_red, green: value_green, blue: value_blue)
            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        }
    }
}

class saved_color: ObservableObject {
    @Published var set_color: Color?
}

let obj_saved_color = saved_color()

class Color_value: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    var red_value = 0.0 { willSet { objectWillChange.send() } }
    var green_value = 0.0 { willSet { objectWillChange.send() } }
    var blue_value = 0.0 { willSet { objectWillChange.send() } }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
