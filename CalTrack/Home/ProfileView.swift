import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authInfo: AuthViewModel
    @EnvironmentObject var app: HomeViewModel
    @State var showingEditSheet = false
    var body: some View {
        NavigationView {
            VStack{
                ScrollView{
                    Text("Instructions (tap to edit)")
                        .font(.custom("Futura", size: 20))
                        .fontWeight(.bold)
                        .frame(alignment:.leading).padding(10)
                        
                    Text(app.instructions)
                        .padding([.leading, .trailing], 20)
                        .frame(maxWidth: .infinity, minHeight: 350, maxHeight: .infinity, alignment: .topLeading)
                }
                .padding([.leading, .trailing], 10).background(Color.secondary)
                .cornerRadius(20.0)
                .onTapGesture {showingEditSheet.toggle()}
                .sheet(isPresented: $showingEditSheet) {editInstruction(data: $app.instructions)}
                
                Spacer().frame( height: 10, alignment: .center)
                    
                Button {authInfo.fireBaseSignOut()}
                    label: {
                        Text("Sign Out")
                            .font(.custom("Futura", size: 20))
                            .fontWeight(.thin)
                            .frame(width: 350, height: 50, alignment: .center)
                            .padding([.leading, .trailing], 20)
                            .cornerRadius(20.0)
                            
                    }
                
                Spacer().frame( height: 10, alignment: .center)
                
                Link("Contact Us", destination: URL(string: "diets@neevnutrition.in")!)
                    .font(.custom("Futura", size: 20))
                    .frame(width: 350, height: 50, alignment: .center)
                    .padding([.leading, .trailing], 20)
                    .cornerRadius(20.0)
                
                Spacer().frame( height: 20, alignment: .center)
                
            }
            .padding([.leading, .trailing], 20)
            .navigationBarTitle("Profile", displayMode: .large)
            .navigationBarBackButtonHidden(true)
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct editInstruction: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var app:  HomeViewModel
    @Binding var data: String
    
    var body: some View {
        ScrollView {
            Text("Instructions").font(.custom("Futura", size: 20)).fontWeight(.bold).padding(10)
        ZStack{
            TextEditor(text: $data)
            Text(data).opacity(0).padding(.all, 8)
        }.padding(10)
            Button {
                
                app.dashboardSummaryPath.setData(["instructions":data], merge: true)
                presentationMode.wrappedValue.dismiss()
 
                
            }
                label: {Text("Done").font(.custom("Futura", size: 20))
                    .fontWeight(.thin)
                    .frame(width: 350, height: 50, alignment: .center)
                    .padding([.leading, .trailing], 20)
                    .background(Color.primary)
                    .cornerRadius(20.0)}
        }
    }
}

