//
//  SELoginData.swift
//
//
//  Created by Andre Albach on 22.09.23.
//

import Foundation

/// The response when the login was successfull.
/// It contain the cookie string which is needed for all further requests.
/// There is also a string with user data in xml format included.
public struct SELoginData {
    
    /// The cookie which is needed for all further requests
    public let cookie: String
    
    /// The user data in an xml format.
    /// Here is an example of what it looks like
    /// <User>
    ///     <email>[EMAIL ADDRESS]</email>
    ///     <locale>de_DE</locale>
    ///     <si>Metrics</si>
    ///     <firstName>[FIRST NAME]</firstName>
    ///     <lastName>[LAST NAME]</lastName>
    ///     <services>
    ///         <service>
    ///             <name>Monitoring</name>
    ///         </service>
    ///     </services>
    ///     <uris>
    ///         <uri key=\"updatelocale\">/user/updatelocale</uri>
    ///         <uri key=\"updateSI\">/user/updateSI</uri>
    ///     </uris>
    ///     <guid>[GUID]</guid>
    /// </User>
    public let xmlUserData: String
}
