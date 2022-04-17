import SwiftUI

struct AuthView: View {
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                
                VStack(alignment: .leading) {
                    
                    Text("Welcome to")
                        .font(.custom("Futura", size: 30))
                        .fontWeight(.semibold)
                    Text("CalTrack")
                        .font(.custom("Futura", size: 70))
                        .fontWeight(.heavy)
                    
                }; Spacer().frame(height: 200, alignment: .center)
                
                NavigationLink(
                    destination: SignUpView(),
                    label: {
                        Text("Create Profile")
                            .font(.custom("Futura", size: 25))
                            .fontWeight(.thin)
                            .frame(width: 300, height: 60, alignment: .center)
                            .padding([.leading, .trailing], 20)
                            .cornerRadius(20.0)
                    }); Spacer().frame( height: 30, alignment: .center)
                
                NavigationLink(
                    destination: LogInView(),
                    label: {
                        Text("Log In")
                            .font(.custom("Futura", size: 25))
                            .fontWeight(.thin)
                            .frame(width: 300, height: 60, alignment: .center)
                            .padding([.leading, .trailing], 20)
                            .cornerRadius(20.0)
                    })
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView().preferredColorScheme(.dark)
    }
}
