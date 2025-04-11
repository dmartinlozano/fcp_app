package com.dmlv.fcp;

import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.car.app.CarAppService;
import androidx.car.app.Screen;
import androidx.car.app.Session;
import androidx.car.app.model.MessageTemplate;
import androidx.car.app.model.Template;
import androidx.car.app.validation.HostValidator;

public class AutoService extends CarAppService {

    @NonNull
    @Override
    public HostValidator createHostValidator() {
        return HostValidator.ALLOW_ALL_HOSTS_VALIDATOR;
    }

    @NonNull
    @Override
    public Session onCreateSession() {
        return new Session() {
            @NonNull
            @Override
            public Screen onCreateScreen(@NonNull Intent intent) {
                return new Screen(getCarContext()) {
                    @NonNull
                    @Override
                    public Template onGetTemplate() {
                        return new MessageTemplate.Builder("¡Hola Mundo desde Android Auto!")
                                .setTitle("Mensaje de Prueba")
                                .build();
                    }
                };
            }
        };
    }
}
