//
//  SecureTextField.swift
//  SecureTextField
//
//  Created by hanwe on 2022/04/23.
//

import UIKit
import SnapKit

final class SecureTextField: UIView {
    
    // MARK: private property
    
    private lazy var keyName: String = UUID().uuidString
    
    // MARK: private UI property
    
    private lazy var textField: UITextField = {
        let textField: UITextField = UITextField()
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private var key: SecKey?
    private var tempSavedString: String? // TODO: 나중에 메모리에 남지 않는 스트링으로 바꾸자.
    private var beforeTextFieldTextCount: Int = 0
    private var encryptedTextData: Data = Data() // TODO: 나중에 메모리에 남지 않는 스트링으로 바꾸자.
    
    // MARK: internal property
    
    // MARK: lifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        KeyChainHelper.removeKey(name: self.keyName)
    }
    
    // MARK: private function
    
    private func setup() {
        initUI()
        prepareKey()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func initUI() {
        
        self.backgroundColor = .clear
        
        self.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
    
    private func prepareKey() {
        self.key = KeyChainHelper.loadKey(name: self.keyName)
        if key == nil {
            do {
                key = try KeyChainHelper.makeAndStoreKey(name: keyName,
                                                         requiresBiometry: false)
            } catch let err {
                print("SecureTextField Error. can't make key: \(err.localizedDescription)")
            }
        }
    }
    
    private func encString(_ input: String) -> Data? {
        guard let key = self.key else { return nil }
        guard let publicKey = SecKeyCopyPublicKey(key) else { return nil }
        let encAlgorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, encAlgorithm) else { return nil }
        var error: Unmanaged<CFError>?
        guard let clearTextData = input.data(using: .utf8) else { return nil }
        guard let cipherTextData = SecKeyCreateEncryptedData(publicKey, encAlgorithm, clearTextData as CFData, &error) as? Data else { return nil }
        return cipherTextData
    }
    
    private func decString(_ encData: Data) -> String? {
        guard let key = key else { return nil }
        let decAlgorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(key, .decrypt, decAlgorithm) else {
            return nil
        }
        var error: Unmanaged<CFError>?
        guard let decTextData = SecKeyCreateDecryptedData(key, decAlgorithm, encData as CFData, &error) as? Data else { return nil }
        if error != nil { return nil }
        guard let returnString: String = String(data: decTextData, encoding: .utf8) else { return nil }
        return returnString
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let inputedText = textField.text else { return }
        print("keyName: \(self.keyName)")
        
        if inputedText.count > self.beforeTextFieldTextCount { // 텍스트가 추가된 경우
            let addedText: String = String(inputedText.last ?? Character.init(""))
            let decStr = decString(self.encryptedTextData) ?? ""
            guard let encData = encString(decStr + addedText) else { return }
            self.encryptedTextData = encData
            self.textField.text?.removeLast()
            self.textField.text = (self.textField.text ?? "") + "-"
        } else if inputedText.count < self.beforeTextFieldTextCount { // 텍스트가 지워진 경우
            var decStr = decString(self.encryptedTextData) ?? ""
            decStr.removeLast()
            guard let encData = encString(decStr) else { return }
            self.encryptedTextData = encData
        } else { // 텍스트가 같다. 안들어올것 같은 경우
            
        }
        self.beforeTextFieldTextCount = self.textField.text?.count ?? 0
    }
    
    // MARK: internal function
    
    // MARK: action

}
