package com.edw.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;

@RestController
public class IndexController {
    private Logger logger = LoggerFactory.getLogger(IndexController.class);

    @GetMapping("/")
    public HashMap index() {
        logger.debug("request served");

        return new HashMap<>() {{
            put("success", true);
            put("hello", "world");
            put("new-message", "adding a new msg");
        }};
    }
}
